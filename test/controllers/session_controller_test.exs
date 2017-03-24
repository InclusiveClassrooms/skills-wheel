defmodule Skillswheel.SessionControllerTest do
  use Skillswheel.ConnCase, async: false

  alias Skillswheel.User

  describe "session routes that don't need authentication" do
    test "Get /sessions/new", %{conn: conn} do
      conn = get conn, session_path(conn, :new)
      assert html_response(conn, 200) =~ "Login"
    end
  end

  describe "session routes that need authentication" do
    setup do
      insert_school()
      insert_user()

      conn = assign(build_conn(), :current_user, Repo.get(User, 1))
      {:ok, conn: conn}
    end

    test "Login: Valid session /sessions/new", %{conn: conn} do
      conn = post conn, session_path(conn, :create,
      %{"session" => %{"email" => "email@test.com", "password" => "password", "admin" => true}})
      assert redirected_to(conn, 302) =~ "/groups"
    end

    test "Login: Invalid session /sessions/new", %{conn: conn} do
      conn = post conn, session_path(conn, :create,
      %{"session" => %{"email" => "invalid@test.com", "password" => "invalid"}})
      assert html_response(conn, 302) =~ "/sessions/new"
    end

    test "Login: Invalid password", %{conn: conn} do
      conn = post conn, session_path(conn, :create,
      %{"session" => %{"email" => "email@test.com", "password" => "invalid"}})
      assert html_response(conn, 302) =~ "/sessions/new"
    end

    test "Logout", %{conn: conn} do
      conn = delete conn, session_path(conn, :delete, conn.assigns.current_user)
      assert redirected_to(conn, 302) =~ "/"
    end
  end
end
