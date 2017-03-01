defmodule Skillswheel.SessionControllerTest do
  use Skillswheel.ConnCase
  alias Skillswheel.User
  alias Skillswheel.School

  describe "session routes that don't need authentication" do
    test "Get /sessions/new", %{conn: conn} do
      conn = get conn, session_path(conn, :new)
      assert html_response(conn, 200) =~ "Login"
    end
  end

  describe "session routes that need authentication" do
    setup do
      %School{
        id: 1,
        name: "Test School",
        email_suffix: "test.com"
      } |> Repo.insert
      
      %User{
        id: 12345,
        name: "My Name",
        email: "email@test.com",
        password_hash: Comeonin.Bcrypt.hashpwsalt("password"),
        school_id: 1
      } |> Repo.insert

      {:ok, conn: build_conn() |> assign(:current_user, Repo.get(User, 12345))}
    end
    test "Login: Valid session /sessions/new", %{conn: conn} do
      conn = post conn, session_path(conn, :create,
      %{"session" => %{"email" => "email@test.com", "password" => "password", "admin" => true}})
      assert redirected_to(conn, 302) =~ "/users"
    end

    test "Login: Invalid session /sessions/new", %{conn: conn} do
      conn = post conn, session_path(conn, :create,
      %{"session" => %{"email" => "invalid@test.com", "password" => "invalid"}})
      assert html_response(conn, 200) =~ "Login"
    end

    test "Login: Invalid password", %{conn: conn} do
      conn = post conn, session_path(conn, :create,
      %{"session" => %{"email" => "email@test.com", "password" => "invalid"}})
      assert html_response(conn, 200) =~ "Login"
    end

    test "Logout", %{conn: conn} do
      conn = delete conn, session_path(conn, :delete, conn.assigns.current_user)
      assert redirected_to(conn, 302) =~ "/"
    end
  end
end
