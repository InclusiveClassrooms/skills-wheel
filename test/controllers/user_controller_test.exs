defmodule Skillswheel.UserControllerTest do
  use Skillswheel.ConnCase
  alias Skillswheel.User

  describe "all user paths that don't need authentication" do
    setup do
      %User{
        id: 12345,
        name: "My Name",
        email: "email@test.com",
        password_hash: Comeonin.Bcrypt.hashpwsalt("password")
      } |> Repo.insert
      :ok
    end

    test "/users/new", %{conn: conn} do
      conn = get conn, user_path(conn, :new)
      assert html_response(conn, 200) =~ "New User"
    end

    test "/users not logged in", %{conn: conn} do
      conn = get conn, user_path(conn, :index)
      assert redirected_to(conn, 302) =~ "/"
      assert conn.halted
    end

    test "/user/:id not logged in ", %{conn: conn} do
      conn = get conn, user_path(conn, :show, 123456)
      assert redirected_to(conn, 302) =~ "/"
      assert conn.halted
    end

    test "create new user", %{conn: conn} do
      conn = post conn, user_path(conn, :create,
      %{"user" => %{
          name: "Test Name",
          email: "test@test.com",
          password: "secretpassword"
        }})
      assert redirected_to(conn, 302) =~ "/users"
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

  describe "all user paths that need authentication" do
    setup do
      %User{
        id: 12345,
        name: "My Name",
        email: "email@test.com",
        password_hash: Comeonin.Bcrypt.hashpwsalt("password")
      } |> Repo.insert

      {:ok, conn: build_conn() |> assign(:current_user, Repo.get(User, 12345))}
    end

    test "/users renders users", %{conn: conn} do
      conn = get conn, user_path(conn, :index)
      assert html_response(conn, 200) =~ "Users"
    end

    test "/user/:id logged in", %{conn: conn} do
      conn = get conn, user_path(conn, :show, 12345)
      assert html_response(conn, 200) =~ "User"
    end
  end

  describe "admin authentication" do
    setup do
      %User{
        id: 12345,
        name: "My Name",
        email: "email@test.com",
        password_hash: Comeonin.Bcrypt.hashpwsalt("password"),
        admin: true
      } |> Repo.insert

      {:ok, conn: build_conn() |> assign(:current_user, Repo.get(User, 12345))}
    end

    test "/users admin", %{conn: conn} do
      conn = get conn, user_path(conn, :index)
      assert html_response(conn, 200) =~ "Users"
    end

    test "/users/:id admin", %{conn: conn} do
      conn = get conn, user_path(conn, :show, 12345)
      assert html_response(conn, 200) =~ "User"
    end
  end
end
