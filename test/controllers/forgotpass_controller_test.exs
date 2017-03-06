defmodule Skillswheel.ForgotpassControllerTest do
  use Skillswheel.ConnCase, async: false
  import Mock

  alias Skillswheel.{RedisCli, ForgotpassController, User, School, Mailer}
  alias Comeonin.Bcrypt

  test "/forgotpass :: index", %{conn: conn} do
    conn = get conn, forgotpass_path(conn, :index)

    assert html_response(conn, 200) =~ "Forgotten Password"
  end

  test "/forgotpass :: create", %{conn: conn} do
    with_mock Mailer, [deliver_now: fn(_) -> nil end] do
      conn = post conn, forgotpass_path(conn, :create,
        %{"forgotpass" => %{"email" => "sehouston3@gmail.com"}})

      assert redirected_to(conn, 302) =~ "/forgotpass"
    end
  end

  test "/forgotpass :: show", %{conn: conn} do
    conn = get conn, forgotpass_path(conn, :show, "s00Rand0m")
    assert html_response(conn, 200) =~ "Reset Password"
    assert html_response(conn, 200) =~ "s00Rand0m"
  end

  describe "/forgotpass :: update_password" do
    setup do
      RedisCli.flushdb()
    end

    test "working flow", %{conn: conn} do
      %School{
        id: 1,
        name: "My school",
        email_suffix: "me.com"
      } |> Repo.insert
      insert_user(%{email: "me@me.com", password: "secret"})
      RedisCli.set("s00Rand0m", "me@me.com")

      conn = post conn, forgotpass_path(conn, :update_password, "s00Rand0m"),
        %{"hash" => "s00Rand0m", "newpass" => %{"password" => "mypass"}}

      assert redirected_to(conn, 302) =~ "/users"
      assert get_flash(conn, :info) == "Password Changed"

      user = Repo.get_by(User, email: "me@me.com")

      refute Bcrypt.checkpw("secret", user.password_hash)
      assert Bcrypt.checkpw("mypass", user.password_hash)
    end

    test "password too short", %{conn: conn} do
      %School{
        id: 1,
        name: "My school",
        email_suffix: "me.com"
      } |> Repo.insert
      insert_user(%{email: "me@me.com", password: "secret"})
      RedisCli.set("s00Rand0m", "me@me.com")

      conn = post conn, forgotpass_path(conn, :update_password, "s00Rand0m"),
        %{"hash" => "s00Rand0m", "newpass" => %{"password" => "short"}}

      assert redirected_to(conn, 302) =~ "/users"
      assert get_flash(conn, :error) == "Invalid password"

      user = Repo.get_by(User, email: "me@me.com")

      assert Bcrypt.checkpw("secret", user.password_hash)
      refute Bcrypt.checkpw("mypass", user.password_hash)
    end

    test "user not in postgres", %{conn: conn} do
      %School{
        id: 1,
        name: "My school",
        email_suffix: "me.com"
      } |> Repo.insert
      RedisCli.set("s00Rand0m", "me@me.com")

      conn = post conn, forgotpass_path(conn, :update_password, "s00Rand0m"),
        %{"hash" => "s00Rand0m", "newpass" => %{"password" => "short"}}

      assert redirected_to(conn, 302) =~ "/users"
      assert get_flash(conn, :error) == "User not in Postgres"

      assert Repo.get_by(User, email: "me@me.com") == nil
    end

    test "user not in redis", %{conn: conn} do
      %School{
        id: 1,
        name: "My school",
        email_suffix: "me.com"
      } |> Repo.insert
      insert_user(%{email: "me@me.com", password: "secret"})

      conn = post conn, forgotpass_path(conn, :update_password, "s00Rand0m"),
        %{"hash" => "s00Rand0m", "newpass" => %{"password" => "mypass"}}

      assert redirected_to(conn, 302) =~ "/users"
      assert get_flash(conn, :error) == "User not in Redis"

      user = Repo.get_by(User, email: "me@me.com")

      assert Bcrypt.checkpw("secret", user.password_hash)
      refute Bcrypt.checkpw("mypass", user.password_hash)
    end

    test "unregistered user without correct suffix", %{conn: conn} do
      conn = post conn, forgotpass_path(conn, :update_password, "s00Rand0m"),
        %{"hash" => "s00Rand0m", "newpass" => %{"password" => "mypass"}}

      assert redirected_to(conn, 302) =~ "/users"
      assert get_flash(conn, :error) == "User not in Redis"
    end

    test "unregistered user with correct suffix", %{conn: conn}do
      %School{
        id: 1,
        name: "My school",
        email_suffix: "me.com"
      } |> Repo.insert
      conn = post conn, forgotpass_path(conn, :update_password, "s00Rand0m"),
        %{"hash" => "s00Rand0m", "newpass" => %{"password" => "mypass"}}

      assert redirected_to(conn, 302) =~ "/users"
      assert get_flash(conn, :error) == "User not in Redis"
    end
  end

  describe "get_email_from_hash" do
    setup do
      RedisCli.flushdb()
    end

    test "user not found in redis" do
      actual = ForgotpassController.get_email_from_hash("s00Rand0m")
      expected = {:error, "User not in Redis"}

      assert actual == expected
    end

    test "user found in redis" do
      RedisCli.set("s00Rand0m", "me@me.com")

      actual = ForgotpassController.get_email_from_hash("s00Rand0m")
      expected = {:ok, "me@me.com"}

      assert actual == expected
    end
  end

  describe "get_user_from_email" do
    test "passes on the error" do
      actual = ForgotpassController.get_user_from_email({:error, "errr"})
      expected = {:error, "errr"}

      assert actual == expected
    end

    test "user not found in postgres" do
      %School{
        id: 1,
        name: "My school",
        email_suffix: "me.com"
      } |> Repo.insert
      actual = ForgotpassController.get_user_from_email({:ok, "me@me.com"})
      expected = {:error, "User not in Postgres"}

      assert actual == expected
    end

    test "user found in postgres" do
      %School{
        id: 1,
        name: "My school",
        email_suffix: "me.com"
      } |> Repo.insert
      insert_user(%{email: "me@me.com", password: "secret"})

      {:ok, actual} = ForgotpassController.get_user_from_email({:ok, "me@me.com"})
      {:ok, expected} = {:ok, %User{email: "me@me.com", name: "user ", password: nil}}

      assert actual.email == expected.email
      assert actual.name =~ expected.name
      assert actual.password == expected.password
    end
  end

  describe "validate_password" do
    test "passes on the error" do
      actual = ForgotpassController.get_user_from_email({:error, "errr"})
      expected = {:error, "errr"}

      assert actual == expected
    end

    test "returns changeset when password is valid" do
      %School{
        id: 1,
        name: "My school",
        email_suffix: "me.com"
      } |> Repo.insert
      insert_user(%{email: "me@me.com", password: "secret"})
      user = Repo.get_by(User, email: "me@me.com")

      {:ok, result} = ForgotpassController.validate_password({:ok, user}, "validpass")

      assert result.changes == %{email: "me@me.com", password: "validpass"}
      assert result.valid?
    end
  end

  describe "put_pass_hash" do
    test "passes on the error" do
      actual = ForgotpassController.put_pass_hash({:error, "errr"})
      expected = {:error, "errr"}

      assert actual == expected
    end

    test "returns a new pass hash" do
      %School{
        id: 1,
        name: "My school",
        email_suffix: "me.com"
      } |> Repo.insert
      insert_user(%{email: "me@me.com", password: "secret"})
      user = Repo.get_by(User, email: "me@me.com")

      old_password_hash = user.password_hash
      params = %{
        "email" => user.email,
        "name" => user.name,
        "password" => "newpass"
      }
      changeset = User.validate_password(%User{}, params)
      {:ok, result} = ForgotpassController.put_pass_hash({:ok, changeset})

      refute result.changes.password_hash == old_password_hash
    end
  end

  describe "update_user" do
    test "passes on the error" do
      actual = ForgotpassController.put_pass_hash({:error, "errr"})
      expected = {:error, "errr"}

      assert actual == expected
    end

    test "updates user in the database" do
      %School{
        id: 1,
        name: "My school",
        email_suffix: "me.com"
      } |> Repo.insert
      insert_user(%{email: "me@me.com", password: "secret"})
      user = Repo.get_by(User, email: "me@me.com")

      old_password_hash = user.password_hash
      params = %{
        "email" => user.email,
        "name" => user.name,
        "password" => "newpass"
      }
      changeset = User.validate_password(%User{}, params)
        |> User.put_pass_hash
      password_hash = Repo.get_by(User, email: "me@me.com").password_hash

      assert password_hash == old_password_hash

      {:ok, new_user} = ForgotpassController.update_user({:ok, changeset})

      refute new_user.password_hash == old_password_hash

      password_hash = Repo.get_by(User, email: "me@me.com").password_hash

      refute password_hash == old_password_hash
    end
  end
end
