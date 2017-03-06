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
      assert get_flash(conn, :error) == "should be at least %{count} character(s)"

      user = Repo.get_by(User, email: "me@me.com")

      assert Bcrypt.checkpw("secret", user.password_hash)
      refute Bcrypt.checkpw("mypass", user.password_hash)
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

      actual = ForgotpassController.get_user_from_email({:ok, "me@me.com"})
      expected = {:ok, %User{email: "me@me.com", name: "user ", password: nil}}

      assert elem(actual, 0) == elem(expected, 0)
      assert elem(actual, 1).email == elem(expected, 1).email
      assert elem(actual, 1).name =~ elem(expected, 1).name
      assert elem(actual, 1).password == elem(expected, 1).password
    end
  end
end
