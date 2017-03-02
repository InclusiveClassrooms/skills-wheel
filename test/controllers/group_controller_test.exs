defmodule Skillswheel.GroupControllerTest do
  use Skillswheel.ConnCase
  alias Skillswheel.User
  alias Skillswheel.Group
  alias Skillswheel.UserGroup

  defp admin_auth(admin?) do
    %User{
      id: 12345,
      name: "My Name",
      email: "email@test.com",
      password_hash: Comeonin.Bcrypt.hashpwsalt("password"),
      admin: admin?
    } |> Repo.insert

    %Group{
      name: "Group 1",
      id: 1
    } |> Repo.insert

    %Group{
      name: "Group 2",
      id: 2
    } |> Repo.insert

    %UserGroup{
      group_id: 1,
      user_id: 12345
    } |> Repo.insert

    if admin? do
      {:ok, conn: build_conn() |> assign(:current_user, Repo.get(User, 12345))}
    else
      :ok
    end


  end

  describe "group paths with authentication" do

    setup do
      admin_auth(true)
    end

    test "/groups", %{conn: conn} do
      conn = get conn, group_path(conn, :index)
      assert html_response(conn, 200) =~ "GROUPS"
    end

    test "/groups/:id", %{conn: conn} do
      conn = get conn, group_path(conn, :show, 1)
      assert html_response(conn, 200) =~ "Group 1"
    end

    test "/groups/:id access denied", %{conn: conn} do
      conn = get conn, group_path(conn, :show, 2)
      assert redirected_to(conn, 302) =~ "/groups"
    end

    test "/groups create", %{conn: conn} do
      conn = post conn, group_path(conn, :create, %{"group" => %{name: "Group 2", id: 10}})
      assert redirected_to(conn, 302) =~ "/groups"
    end

    test "/groups create invalid", %{conn: conn} do
      conn = post conn, group_path(conn, :create, %{"group" => %{name: "", id: 20}})
      assert redirected_to(conn, 302) =~ "/groups"
    end

    test "/groups create assign unsuccessful", %{conn: conn} do
      conn =
        conn
        |> assign(:current_user, %Skillswheel.User{})
      conn = post conn, group_path(conn, :create, %{"group" => %{name: "Test", id: 30}})
      assert redirected_to(conn, 302) =~ "/groups"
    end


  end

  describe "group paths without authentication" do

    setup do
      admin_auth(false)
    end

    test "/groups", %{conn: conn} do
      conn = get conn, group_path(conn, :index)
      assert redirected_to(conn, 302) =~ "/"
    end

    test "/groups/:id", %{conn: conn} do
      conn = get conn, group_path(conn, :show, 1)
      assert redirected_to(conn, 302) =~ "/"
    end
  end
end
