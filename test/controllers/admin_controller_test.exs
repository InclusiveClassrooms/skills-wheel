defmodule Skillswheel.AdminControllerTest do
  use Skillswheel.ConnCase

  alias Skillswheel.User

  defp admin_auth(admin?) do
    %User{
      id: 12345,
      name: "My Name",
      email: "email@test.com",
      password_hash: Comeonin.Bcrypt.hashpwsalt("password"),
      admin: admin?
    } |> Repo.insert

    {:ok, conn: build_conn() |> assign(:current_user, Repo.get(User, 12345))}
  end

  describe "admin authorised" do
    setup do
      admin_auth(true)
    end

    test "/admin", %{conn: conn} do
      conn = get conn, admin_path(conn, :index)
      assert html_response(conn, 200) =~ "ADMIN DASHBOARD"
    end
  end


  describe "admin unauthorised" do
    setup do
      admin_auth(false)
    end

    test "/admin", %{conn: conn} do
      conn = get conn, admin_path(conn, :index)
      assert redirected_to(conn, 302) =~ "/"
    end
  end
end
