defmodule Skillswheel.AdminControllerTest do
  use Skillswheel.ConnCase

  alias Skillswheel.User

  setup do
    %User{
      id: 12345,
      name: "My Name",
      email: "email@test.com",
      password_hash: Comeonin.Bcrypt.hashpwsalt("password")
    } |> Repo.insert

    {:ok, conn: build_conn() |> assign(:current_user, Repo.get(User, 12345))}
  end

  test "/admin", %{conn: conn} do
    conn = get conn, admin_path(conn, :index)
    assert html_response(conn, 200) =~ "ADMIN DASHBOARD"
  end
end
