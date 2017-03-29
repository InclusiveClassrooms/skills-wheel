defmodule Skillswheel.UserControllerTest do
  use Skillswheel.ConnCase, async: false

  alias Comeonin.Bcrypt

  describe "creating new user" do
    setup do
      insert_school()
      insert_validated_user(%{password_hash: Bcrypt.hashpwsalt("password")})

      :ok
    end

    test "email doesn't already exist", %{conn: conn} do
      conn = post conn, user_path(conn, :create,
      %{"user" => %{
          name: "Test Name",
          email: "test@test.com",
          password: "secretpassword",
          school_id: 1,
          admin: true
        }})
      assert redirected_to(conn, 302) =~ "/groups"
    end

    test "email already exists", %{conn: conn} do
      conn = post conn, user_path(conn, :create,
      %{"user" => %{
          name: "Test Name",
          email: "email@test.com",
          password: "secretpassword"
        }})
      assert html_response(conn, 302) =~ "/sessions/new"
    end
  end
end
