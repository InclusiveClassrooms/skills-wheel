defmodule Skillswheel.UserControllerTest do
  use Skillswheel.ConnCase, async: false

  alias Skillswheel.{User, School}
  alias Comeonin.Bcrypt

  describe "all user paths that don't need authentication" do
    setup do
      %School{
        id: 1,
        name: "Test School",
        email_suffix: "test.com"
      } |> Repo.insert
      :ok

      %User{
        id: 12345,
        name: "My Name",
        email: "email@test.com",
        password_hash: Bcrypt.hashpwsalt("password")
      } |> Repo.insert
      :ok
    end

    test "/users/new", %{conn: conn} do
      conn = get conn, user_path(conn, :new)
      assert html_response(conn, 200) =~ "New User"
    end

    test "create new user", %{conn: conn} do
      conn = post conn, user_path(conn, :create,
      %{"user" => %{
          name: "Test Name",
          email: "test@test.com",
          password: "secretpassword",
          school_id: 1,
          admin: true
        }})
      assert redirected_to(conn, 302) =~ "/groups"
    end

    test "Sign up fail: existing email", %{conn: conn} do
      conn = post conn, user_path(conn, :create,
      %{"user" => %{
          name: "Test Name",
          email: "email@test.com",
          password: "secretpassword"
        }})
      assert html_response(conn, 200) =~ "New User"
    end
  end
end
