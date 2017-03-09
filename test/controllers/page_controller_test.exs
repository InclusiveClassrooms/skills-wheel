defmodule Skillswheel.PageControllerTest do
  use Skillswheel.ConnCase

  test "Get / User not logged in", %{conn: conn} do
    conn = get conn, page_path(conn, :index)
    assert redirected_to(conn, 302) =~ "/sessions/new"
  end
end
