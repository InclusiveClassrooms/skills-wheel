defmodule Skillswheel.SessionControllerTest do
  use Skillswheel.ConnCase

  test "Get /sessions/new", %{conn: conn} do
    conn = get conn, session_path(conn, :new)
    assert html_response(conn, 200) =~ "Login"
  end
end
