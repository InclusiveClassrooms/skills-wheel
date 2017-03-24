defmodule Skillswheel.SchoolControllerTest do
  use Skillswheel.ConnCase, async: false

  alias Skillswheel.{User, School}

  @valid_attrs %{name: "Test", email_suffix: "test.org"}
  @invalid_attrs %{name: "", email_suffix: ""}

  setup do
    insert_user(%{admin: true})
    conn = assign(build_conn(), :current_user, Repo.get(User, 1))

    {:ok, conn: conn}
  end

  test "/school/new", %{conn: conn} do
    conn = post conn, school_path(conn, :create, %{"school" => @valid_attrs})
    assert redirected_to(conn, 302) =~ "/admin"
  end

  test "/school/new invalid", %{conn: conn} do
    conn = post conn, school_path(conn, :create, %{"school" => @invalid_attrs})
    assert redirected_to(conn, 302) =~ "/admin"
  end

  test "/school/:id delete", %{conn: conn} do
    insert_school()
    conn = delete conn, school_path(conn, :delete, %School{id: 1})

    assert redirected_to(conn, 302) =~ "/admin"
  end
end
