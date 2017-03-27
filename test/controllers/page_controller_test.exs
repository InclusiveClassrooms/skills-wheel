defmodule Skillswheel.PageControllerTest do
  use Skillswheel.ConnCase
  alias Skillswheel.User

  test "Get / User not logged in", %{conn: conn} do
    conn = get conn, page_path(conn, :index)
    assert redirected_to(conn, 302) =~ "/sessions/new"
  end

  test "Get / User logged in", %{conn: conn} do
    insert_school()
    insert_user()
    conn =
      conn
      |> assign(:current_user, Repo.get_by(User, email: "email@test.com"))
    conn = get conn, page_path(conn, :index)
    assert redirected_to(conn, 302) =~ "/groups"
  end
end
