defmodule Skillswheel.GroupControllerTest do
  use Skillswheel.ConnCase, async: false

  alias Skillswheel.{User, Group}

  defp admin_auth(admin?) do
    insert_user(%{admin: admin?})
    conn = assign(build_conn(), :current_user, Repo.get(User, 1))

    if admin? do
      {:ok, conn: conn}
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
      insert_group()
      insert_usergroup()

      conn = assign(conn, :current_user, Repo.get(User, 1))
      conn = get conn, group_path(conn, :show, 1)
      assert html_response(conn, 200) =~ "Group 1"
    end

    test "/groups/:id update", %{conn: conn} do
      insert_group()
      insert_usergroup()

      conn = assign(conn, :current_user, Repo.get(User, 1))
      conn = put conn, group_path(conn, :update, 1, %{"id" => "1", "group" => %{"name" => "test"}})

      assert redirected_to(conn, 302) =~ "/groups/1"
    end

    test "/groups/:id update with bad information", %{conn: conn} do
      insert_group()
      insert_usergroup()

      conn = assign(conn, :current_user, Repo.get(User, 1))
      conn = put conn, group_path(conn, :update, 1, %{"id" => "1", "group" => %{"name" => ""}})

      assert redirected_to(conn, 302) =~ "/groups/1"
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
      insert_group()

      conn = post conn, group_path(conn, :invite, 1, %{"email_params" => %{"email" => "email@test.com"}, "group_id" => "1"})
      assert redirected_to(conn, 302) =~ "/groups/1"
    end

    test "invite non-skillswheel user to group", %{conn: conn} do
      insert_group()

      conn = post conn, group_path(conn, :invite, 1, %{"email_params" => %{"email" => "user@notregistered.com"}, "group_id" => "1"})
      assert redirected_to(conn, 302) =~ "/groups/1"
    end

    test "teaching assistant already added", %{conn: conn} do
      insert_group()
      insert_usergroup()

      conn = post conn, group_path(conn, :invite, 1, %{"email_params" => %{"email" => "email@test.com"}, "group_id" => "1"})
      assert redirected_to(conn, 302) =~ "/groups/1"
    end

    test "group/:id delete", %{conn: conn} do
      insert_group()

      conn = delete conn, group_path(conn, :delete, %Group{id: 1})
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
