defmodule Skillswheel.SurveyControllerTest do
  use Skillswheel.ConnCase
  alias Skillswheel.{User, Student, Group, Survey, UserGroup}
  import Mock

  describe "/survey :: create_survey" do
    test "Successful new survey", %{conn: conn} do
      %Group{
        name: "Test Group 1",
        id: 1
      } |> Repo.insert
      group = Repo.get!(Group, 1)
      changeset = Ecto.build_assoc(group, :students)
        |> Student.changeset(%{
          first_name: "First",
          last_name: "Last",
          sex: "male",
          year_group: "5",
          group_id: 1
        })

      {:ok, student} = changeset |> Repo.insert
      conn = post conn, survey_path(conn, :create_survey, student.id),
        %{"survey" => Map.new(Survey.elems, fn atom -> {atom, Atom.to_string(atom)} end)}

      assert redirected_to(conn, 302) == "/students/" <> Integer.to_string(student.id)
      assert get_flash(conn, :info) == "Survey submitted"
      with_mock HTTPotion, [post: fn(_url) -> nil end] do
      end
    end

    test "Unsuccessful survey request", %{conn: conn} do
      %Group{
        name: "Test Group 1",
        id: 1
      } |> Repo.insert
      group = Repo.get!(Group, 1)
      changeset = Ecto.build_assoc(group, :students)
        |> Student.changeset(%{
          first_name: "First",
          last_name: "Last",
          sex: "male",
          year_group: "5",
          group_id: 1
        })
      {:ok, student} = changeset |> Repo.insert

      conn = post conn, survey_path(conn, :create_survey, student.id),
        %{"survey" => Map.new(Survey.elems, fn atom -> {atom, ""} end)}
      assert redirected_to(conn, 302) == "/students/" <> Integer.to_string(student.id)
      assert get_flash(conn, :error) == "Error creating survey"
      with_mock HTTPotion, [post: fn(_url) -> nil end] do
      end
    end
  end

  describe "/survey/:student_id :: show" do
    test "shows the form", %{conn: conn} do
      %User{
        id: 1234,
        name: "My Name",
        email: "email@test.com",
        password_hash: Comeonin.Bcrypt.hashpwsalt("password"),
        admin: true
      } |> Repo.insert
      %Group{
        name: "Test Group 1",
        id: 1
      } |> Repo.insert
      %UserGroup{
        group_id: 1,
        user_id: 1234
      } |> Repo.insert
      %Student{
        id: 1,
        first_name: "First",
        last_name: "Last",
        sex: "male",
        year_group: "2",
        group_id: 1
      } |> Repo.insert
      struct(Survey, Map.new(Survey.elems, fn atom -> {atom, (if atom == :student_id do 1 else "1" end)} end)) |> Repo.insert


      conn =
        conn
        |> assign(:current_user, Repo.get(User, 1234))

      conn = get conn, survey_path(conn, :show, 1)

      assert html_response(conn, 200) =~ "Assessment Questionaire"
    end

    test "unknown student id redirects back to groups", %{conn: conn} do
      %User{
        id: 1234,
        name: "My Name",
        email: "email@test.com",
        password_hash: Comeonin.Bcrypt.hashpwsalt("password"),
        admin: true
      } |> Repo.insert

      conn =
        conn
        |> assign(:current_user, Repo.get(User, 1234))

      conn = get conn, survey_path(conn, :show, 1)

      assert redirected_to(conn, 302) =~ "/groups"
    end

    test "known student which is not yours redirects back to groups" , %{conn: conn} do
      %User{
        id: 123,
        name: "My Name",
        email: "email@test.com",
        password_hash: Comeonin.Bcrypt.hashpwsalt("password"),
        admin: true
      } |> Repo.insert

      %Group{
        name: "Test Group 3",
        id: 3
      } |> Repo.insert

      %Group{
        name: "Test Group 4",
        id: 4
      } |> Repo.insert

      %UserGroup{
        group_id: 3,
        user_id: 123
      } |> Repo.insert

      %Student{
        id: 3,
        first_name: "First",
        last_name: "Last",
        sex: "male",
        year_group: "2",
        group_id: 3
      } |> Repo.insert

      %Student{
        id: 4,
        first_name: "First",
        last_name: "Last",
        sex: "male",
        year_group: "2",
        group_id: 4
      } |> Repo.insert

      conn =
        conn
        |> assign(:current_user, Repo.get(User, 123))

      conn = get conn, survey_path(conn, :show, 4)
      assert redirected_to(conn, 302) =~ "/groups"
    end
  end
end
