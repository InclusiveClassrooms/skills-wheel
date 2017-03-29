defmodule Skillswheel.UserGroupControllerTest do
  use Skillswheel.ConnCase, async: false
  
  alias Skillswheel.User

  test "remove teaching assistant from group", %{conn: conn} do

    insert_user(%{admin: true})
    insert_user(%{id: 2, email: "email@test2.com"})
    insert_group()
    insert_usergroup()
    insert_usergroup(%{user_id: 2})

    conn = assign(conn, :current_user, Repo.get(User, 1))

    conn = delete conn, user_group_path(conn, :delete, 2, %{"id" => "2", "user_params" => %{"user_id" => "2"}})
    assert redirected_to(conn, 302) == "/groups/2"
  end
end
