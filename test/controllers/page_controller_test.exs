defmodule Skillswheel.PageControllerTest do
  use Skillswheel.ConnCase

  test "Get / User not logged in", %{conn: conn} do
    conn = get conn, page_path(conn, :index)
    assert html_response(conn, 200) =~ "Inclusive Classrooms"
    assert html_response(conn, 200) =~ "Hello, World"
  end
end
