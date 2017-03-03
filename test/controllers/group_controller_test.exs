defmodule Skillswheel.GroupControllerTest do
  use Skillswheel.ConnCase, async: false
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
      %User{
        id: 123456,
        name: "My Name",
        email: "email@test2.com",
        password_hash: Comeonin.Bcrypt.hashpwsalt("password"),
        admin: true
      } |> Repo.insert

      conn =
        conn
        |> assign(:current_user, Repo.get(User, 123456))

      %Group{
        name: "Group 1",
        id: 1
      } |> Repo.insert 

      %UserGroup{
        group_id: 1,
        user_id: 123456
      } |> Repo.insert


      conn = get conn, group_path(conn, :show, 1)
      assert html_response(conn, 200) =~ "Group 1"
    end

    test "/groups/:id access denied", %{conn: conn} do
      %Group{
        name: "Group 2",
        id: 2
      } |> Group.changeset |> Repo.insert
      conn = get conn, group_path(conn, :show, 2)
      assert redirected_to(conn, 302) =~ "/groups"
    end

    test "/groups create", %{conn: conn} do
      conn = post conn, group_path(conn, :create, %{"group" => %{name: "Group Two"}})
      assert redirected_to(conn, 302) =~ "/groups"
    end

    test "/groups create invalid", %{conn: conn} do
      conn = post conn, group_path(conn, :create, %{"group" => %{name: ""}})
      assert redirected_to(conn, 302) =~ "/groups"
    end

    test "/groups create assign unsuccessful", %{conn: conn} do
      conn =
        conn
        |> assign(:current_user, %Skillswheel.User{})
      conn = post conn, group_path(conn, :create, %{"group" => %{name: "Test Group"}})
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
