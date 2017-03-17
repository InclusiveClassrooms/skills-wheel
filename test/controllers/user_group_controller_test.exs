defmodule Skillswheel.UserGroupControllerTest do
  use Skillswheel.ConnCase, async: false
  
  alias Skillswheel.{User, Group, UserGroup}
  alias Comeonin.Bcrypt

  test "remove teaching assistant from group", %{conn: conn} do
    %User{
      id: 321,
      name: "Test 1",
      email: "email@test321.com",
      password_hash: Bcrypt.hashpwsalt("password"),
      admin: true
    } |> Repo.insert

    conn =
      conn
      |> assign(:current_user, Repo.get(User, 321))

    %User{
      id: 123,
      name: "Test 2",
      email: "email@test123.com",
      password_hash: Bcrypt.hashpwsalt("password"),
      admin: true
    } |> Repo.insert

    %Group{
      name: "Group 1",
      id: 1
    } |> Repo.insert

    %UserGroup{
      group_id: 1,
      user_id: 321
    } |> Repo.insert

    %UserGroup{
      group_id: 1,
      user_id: 123
    } |> Repo.insert

    conn = delete conn, user_group_path(conn, :delete, 1, %{"id" => "1", "user_params" => %{"user_id" => "123"}})
    assert redirected_to(conn, 302) =~ "groups/1"
  end
end
