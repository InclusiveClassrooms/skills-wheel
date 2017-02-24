defmodule Skillswheel.UserControllerTest do
  use Skillswheel.ConnCase
  alias Skillswheel.User

  setup do
    %User{
      id: 123456,
      name: "First Last",
      email: "test@gmail.com",
      password_hash: Comeonin.Bcrypt.hashpwsalt("password"),
      admin: false
    } |> Repo.insert

    {:ok, user: Repo.get(User, 123456)}
  end

  test "/users/new", %{conn: conn} do
    conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "New User"
  end

  test "/users not logged in", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert redirected_to(conn, 302) =~ "/"
  end

  test "/user/:id not logged in ", %{conn: conn} do
    conn = get conn, user_path(conn, :show, 123456)
    assert redirected_to(conn, 302) =~ "/"
  end

end
