defmodule Skillswheel.ForgotpassControllerTest do
  use Skillswheel.ConnCase, async: false
  import Mock

  alias Skillswheel.{RedisCli, ForgotpassController, User, Mailer}
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
      insert_school()
      insert_validated_user()
      RedisCli.set("s00Rand0m", "email@test.com")

      conn = post conn, forgotpass_path(conn, :update_password, "s00Rand0m"),
        %{"hash" => "s00Rand0m", "newpass" => %{"password" => "newpass"}}

      assert redirected_to(conn, 302) =~ "/groups"
      assert get_flash(conn, :info) == "Password Changed"

      user = Repo.get_by(User, email: "email@test.com")

      refute Bcrypt.checkpw("supersecret", user.password_hash)
      assert Bcrypt.checkpw("newpass", user.password_hash)
    end

    test "password too short", %{conn: conn} do
      insert_school()
      insert_validated_user()
      RedisCli.set("s00Rand0m", "email@test.com")

      conn = post conn, forgotpass_path(conn, :update_password, "s00Rand0m"),
        %{"hash" => "s00Rand0m", "newpass" => %{"password" => "short"}}

      assert redirected_to(conn, 302) =~ "/forgotpass/s00Rand0m"
      assert get_flash(conn, :error) == "Invalid, ensure your password is 6-20 characters"

      user = Repo.get_by(User, email: "email@test.com")

      assert Bcrypt.checkpw("supersecret", user.password_hash)
      refute Bcrypt.checkpw("mypass", user.password_hash)
    end

    test "user not in postgres", %{conn: conn} do
      insert_school()
      RedisCli.set("s00Rand0m", "me@test.com")

      conn = post conn, forgotpass_path(conn, :update_password, "s00Rand0m"),
        %{"hash" => "s00Rand0m", "newpass" => %{"password" => "short"}}

      assert redirected_to(conn, 302) =~ "/users"
      assert get_flash(conn, :error) == "User has not been registered"

      assert Repo.get_by(User, email: "me@test.com") == nil
    end

    test "user not in redis", %{conn: conn} do
      insert_school()
      insert_validated_user(%{email: "me@test.com", password: "secret"})

      conn = post conn, forgotpass_path(conn, :update_password, "s00Rand0m"),
        %{"hash" => "s00Rand0m", "newpass" => %{"password" => "newpass"}}

      assert redirected_to(conn, 302) =~ "/users"
      assert get_flash(conn, :error) == "The email link has expired"

      user = Repo.get_by(User, email: "me@test.com")

      assert Bcrypt.checkpw("secret", user.password_hash)
      refute Bcrypt.checkpw("newpass", user.password_hash)
    end

    test "unregistered user without correct suffix", %{conn: conn} do
      conn = post conn, forgotpass_path(conn, :update_password, "s00Rand0m"),
        %{"hash" => "s00Rand0m", "newpass" => %{"password" => "newpass"}}

      assert redirected_to(conn, 302) =~ "/users"
      assert get_flash(conn, :error) == "The email link has expired"
    end

    test "unregistered user with correct suffix", %{conn: conn}do
      insert_school()
      conn = post conn, forgotpass_path(conn, :update_password, "s00Rand0m"),
        %{"hash" => "s00Rand0m", "newpass" => %{"password" => "newpass"}}

      assert redirected_to(conn, 302) =~ "/users"
      assert get_flash(conn, :error) == "The email link has expired"
    end
  end

  describe "get_email_from_hash" do
    setup do
      RedisCli.flushdb()
    end

    test "user not found in redis" do
      actual = ForgotpassController.get_email_from_hash("s00Rand0m")
      expected = {:error, "The email link has expired"}

      assert actual == expected
    end

    test "user found in redis" do
      RedisCli.set("s00Rand0m", "me@test.com")

      actual = ForgotpassController.get_email_from_hash("s00Rand0m")
      expected = {:ok, "me@test.com"}

      assert actual == expected
    end
  end

  describe "get_user_from_email" do
    test "user not found in postgres" do
      insert_school()
      actual = ForgotpassController.get_user_from_email("me@test.com")
      expected = {:error, "User has not been registered"}

      assert actual == expected
    end

    test "user found in postgres" do
      insert_school()
      insert_user(%{email: "me@test.com", password: "secret"})

      {:ok, actual} = ForgotpassController.get_user_from_email("me@test.com")
      {:ok, expected} = {:ok, %User{email: "me@test.com", name: "My Name", password: nil}}

      assert actual.email == expected.email
      assert actual.name == expected.name
      assert actual.password == expected.password
    end
  end

  describe "validate_password" do
    test "returns changeset when password is valid" do
      insert_school()
      insert_user(%{email: "me@test.com", password: "secret"})
      user = Repo.get_by(User, email: "me@test.com")

      {:ok, result} = ForgotpassController.validate_password(user, "validpass")

      assert result.changes == %{email: "me@test.com", password: "validpass"}
      assert result.valid?
    end
  end

  describe "put_pass_hash" do
    test "returns a new pass hash" do
      insert_school()
      insert_user(%{email: "me@test.com", password: "secret"})
      user = Repo.get_by(User, email: "me@test.com")

      old_password_hash = user.password_hash
      params = %{
        "email" => user.email,
        "name" => user.name,
        "password" => "newpass"
      }
      changeset = User.validate_password(%User{}, params)
      {:ok, result} = ForgotpassController.put_pass_hash(changeset)

      refute result.changes.password_hash == old_password_hash
    end
  end

  describe "update_user" do
    test "updates user in the database" do
      insert_school()
      insert_user(%{email: "me@test.com", password: "secret"})
      user = Repo.get_by(User, email: "me@test.com")

      old_password_hash = user.password_hash
      params = %{
        "email" => user.email,
        "name" => user.name,
        "password" => "newpass"
      }
      changeset = User.validate_password(%User{}, params)
        |> User.put_pass_hash
      password_hash = Repo.get_by(User, email: "me@test.com").password_hash

      assert password_hash == old_password_hash

      {:ok, new_user} = ForgotpassController.update_user(changeset)

      refute new_user.password_hash == old_password_hash

      password_hash = Repo.get_by(User, email: "me@test.com").password_hash

      refute password_hash == old_password_hash
    end
  end
end
