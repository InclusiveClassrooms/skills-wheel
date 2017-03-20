defmodule Skillswheel.GroupControllerTest do
  use Skillswheel.ConnCase, async: false

  alias Skillswheel.{User, Group, UserGroup}
  alias Comeonin.Bcrypt

  defp admin_auth(admin?) do
    %User{
      id: 12345,
      name: "My Name",
      email: "email@test.com",
      password_hash: Bcrypt.hashpwsalt("password"),
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
      assert html_response(conn, 200) =~ "Add Group"
    end

    test "/groups/:id", %{conn: conn} do
      %User{
        id: 123456,
        name: "My Name",
        email: "email@test2.com",
        password_hash: Bcrypt.hashpwsalt("password"),
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

    test "/groups/:id update", %{conn: conn} do
      %User{
        id: 1234567,
        name: "My Name",
        email: "email@test2.com",
        password_hash: Bcrypt.hashpwsalt("password"),
        admin: true
      } |> Repo.insert

      conn =
        conn
        |> assign(:current_user, Repo.get(User, 1234567))

      %Group{
        name: "Group 30",
        id: 30
      } |> Repo.insert

      %UserGroup{
        group_id: 30,
        user_id: 1234567
      } |> Repo.insert



      conn = put conn, group_path(conn, :update, 30, %{"id" => "30", "group" => %{"name" => "test"}})
      assert redirected_to(conn, 302) =~ "/groups/30"
    end

    test "/groups/:id update with bad information", %{conn: conn} do
      %User{
        id: 12345678,
        name: "My Name",
        email: "email@test3.com",
        password_hash: Bcrypt.hashpwsalt("password"),
        admin: true
      } |> Repo.insert

      conn =
        conn
        |> assign(:current_user, Repo.get(User, 12345678))

      %Group{
        name: "Group 31",
        id: 31
      } |> Repo.insert

      %UserGroup{
        group_id: 31,
        user_id: 12345678
      } |> Repo.insert

      conn = put conn, group_path(conn, :update, 31, %{"id" => "31", "group" => %{"name" => ""}})
      assert redirected_to(conn, 302) =~ "/groups/31"
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
        |> assign(:current_user, %User{})
      conn = post conn, group_path(conn, :create, %{"group" => %{name: "Test Group"}})
      assert redirected_to(conn, 302) =~ "/groups"
    end

    test "invite user to group", %{conn: conn} do
      %Group{
        name: "Group 36",
        id: 6
      } |> Repo.insert

      %User{
        id: 11111,
        name: "My Name",
        email: "email@test11.com",
        password_hash: Bcrypt.hashpwsalt("password"),
        admin: true
      } |> Repo.insert
      conn = post conn, group_path(conn, :invite, 6, %{"email_params" => %{"email" => "email@test11.com"}, "group_id" => "6"})
      assert redirected_to(conn, 302) =~ "/groups/6"
    end

    test "invite non-skillswheel user to group", %{conn: conn} do
      %Group{
        name: "Group 7",
        id: 7
      } |> Repo.insert

      conn = post conn, group_path(conn, :invite, 7, %{"email_params" => %{"email" => "user@notregistered.com"}, "group_id" => "7"})
      assert redirected_to(conn, 302) =~ "/groups/7"
    end

    test "teaching assistant already added", %{conn: conn} do
      %User{
        id: 22,
        name: "My Name",
        email: "email@test22.com",
        password_hash: Bcrypt.hashpwsalt("password"),
        admin: true
      } |> Repo.insert

      %Group{
        name: "Group 9",
        id: 9
      } |> Repo.insert

      %UserGroup{
        group_id: 9,
        user_id: 22
      } |> Repo.insert

      conn = post conn, group_path(conn, :invite, 9, %{"email_params" => %{"email" => "email@test22.com"}, "group_id" => "9"})
      assert redirected_to(conn, 302) =~ "/groups/9"
    end

    test "group/:id delete", %{conn: conn} do
      %Group{
        name: "Test Group",
        id: 123
      } |> Repo.insert
      conn = delete conn, group_path(conn, :delete, struct(Group, %{id: 123}))
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
