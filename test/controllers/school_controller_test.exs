defmodule Skillswheel.SchoolControllerTest do
  use Skillswheel.ConnCase

  alias Skillswheel.User
  alias Skillswheel.School

  @valid_attrs %{name: "Test", email_suffix: "test.org"}
  @invalid_attrs %{name: "", email_suffix: ""}

  setup do
    %User{
      id: 12345,
      name: "My Name",
      email: "email@test.com",
      password_hash: Comeonin.Bcrypt.hashpwsalt("password")
    } |> Repo.insert

    {:ok, conn: build_conn() |> assign(:current_user, Repo.get(User, 12345))}
  end

  test "/school/new", %{conn: conn} do
    conn = post conn, school_path(conn, :create, %{"school" => @valid_attrs})
    assert redirected_to(conn, 302) =~ "/admin"
  end

  test "/school/new invalid", %{conn: conn} do
    conn = post conn, school_path(conn, :create, %{"school" => @invalid_attrs})
    assert redirected_to(conn, 302) =~ "/admin"
  end
end
