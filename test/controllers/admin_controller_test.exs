defmodule Skillswheel.AdminControllerTest do
  use Skillswheel.ConnCase, async: false

  alias Skillswheel.{User, AdminController, UserGroup,
                     Group, School, Student, Survey}
  alias Comeonin.Bcrypt

  defp admin_auth(admin?) do
    %User{
      id: 12345,
      name: "My Name",
      email: "email@test.com",
      password_hash: Bcrypt.hashpwsalt("password"),
      admin: admin?
    } |> Repo.insert

    {:ok, conn: build_conn() |> assign(:current_user, Repo.get(User, 12345))}
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
      %School{
        id: 1,
        name: "Test School",
        email_suffix: "test.com"
      } |> Repo.insert
      %User{
        id: 12345,
        name: "My Name",
        email: "email@test.com",
        password_hash: Bcrypt.hashpwsalt("password"),
        school_id: 1,
        admin: true
      } |> Repo.insert
      %Group{
        name: "Group 1",
        id: 1
      } |> Repo.insert
      %UserGroup{
        group_id: 1,
        user_id: 12345
      } |> Repo.insert
      %Student{
        id: 1,
        first_name: "First",
        last_name: "Last",
        sex: "male",
        year_group: "2",
        group_id: 1
      } |> Repo.insert
        struct(Survey, Map.new(Survey.elems, fn atom ->
          {
            atom,
            (if atom == :student_id do 1 else "1" end)
          }
        end)) |> Repo.insert

      :ok
    end

    test "/admin" do
      actual =
        AdminController.all_survey_data()
        |> Enum.map(&(Map.delete(&1, "Date")))
      expected = [
        %{"Child Name" => "First Last",
          "Group Name" => "Group 1",
          "Managing Feelings" => 5,
          "Non-Verbal Communication" => 5,
          "Planning & Problem Solving" => 5,
          "Relationships, Leaderships & Assertiveness" => 5,
          "School Name" => "Test School",
          "Self Awareness & Self-Esteem" => 5,
          "Survey Total" => 30,
          "Teaching Assistant" => "My Name",
          "Verbal Communication" => 5,
          "Year" => "2"}]

      assert actual == expected
    end
  end
end
