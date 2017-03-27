defmodule Skillswheel.AdminControllerTest do
  use Skillswheel.ConnCase, async: false

  alias Skillswheel.{User, AdminController}

  defp admin_auth(admin?) do
    insert_user(%{admin: admin?})
    conn = assign(build_conn(), :current_user, Repo.get(User, id().user))

    {:ok, conn: conn}
  end

  describe "admin authorised" do
    setup do
      admin_auth(true)
    end

    test "/admin", %{conn: conn} do
      conn = get conn, admin_path(conn, :index)
      assert html_response(conn, 200) =~ "ADMIN DASHBOARD"
    end
  end

  describe "admin unauthorised" do
    setup do
      admin_auth(false)
    end

    test "/admin", %{conn: conn} do
      conn = get conn, admin_path(conn, :index)
      assert redirected_to(conn, 302) =~ "/"
    end
  end

  describe "all_survey_data function" do
    setup do
      insert_school()
      insert_user(%{school_id: id().school})
      insert_group()
      insert_usergroup()
      insert_student()
      insert_survey()

      :ok
    end

    test "/admin" do
      actual =
        AdminController.all_survey_data()
        |> Enum.map(&(Map.delete(&1, "Date")))
      expected = [
        %{"Child Name" => "First Last",
          "Group Name" => "Group #{id().group}",
          "Managing Feelings" => 5,
          "Non-Verbal Communication" => 5,
          "Planning & Problem Solving" => 5,
          "Relationships, Leaderships & Assertiveness" => 5,
          "School Name" => "Test School",
          "Self Awareness & Self-Esteem" => 5,
          "Survey Total" => 30,
          "Teaching Assistant" => "My Name",
          "Verbal Communication" => 5,
          "Year" => "1"}]

      assert actual == expected
    end
  end
end
