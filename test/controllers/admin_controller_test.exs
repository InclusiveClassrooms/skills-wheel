defmodule Skillswheel.AdminControllerTest do
  use Skillswheel.ConnCase, async: false

  alias Skillswheel.{User, AdminController}
  alias Comeonin.Bcrypt

  defp admin_auth(admin?) do
    %User{
      id: 12345,
      name: "My Name",
      email: "email@test.com",
      password_hash: Bcrypt.hashpwsalt("password"),
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

  describe "all_survey_data function" do
    setup do
      :ok
    end

    test "returned list" do
      assert AdminController.all_survey_data() == []
    end
  end
end
