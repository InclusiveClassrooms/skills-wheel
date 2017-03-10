defmodule Skillswheel.SurveyControllerTest do
  use Skillswheel.ConnCase
  alias Skillswheel.{User, Student, Group, Survey, UserGroup}

  describe "/survey :: create" do
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

      conn = post conn, survey_path(conn, :create,
        %{"survey" => Map.new(Survey.elems, fn atom -> {
            atom,
            if atom == :student_id do student.id else Atom.to_string(atom) end
          } end)
        })

      assert redirected_to(conn, 302) == "/students/" <> Integer.to_string(student.id)
      assert get_flash(conn, :info) == "Survey created!"
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

      conn = post conn, survey_path(conn, :create,
        %{"survey" => Map.new(Survey.elems, fn atom -> {
            atom,
            if atom == :student_id do student.id else "" end
          } end)
        })

      assert redirected_to(conn, 302) == "/students/" <> Integer.to_string(student.id)
      assert get_flash(conn, :error) == "Error creating survey"
    end
  end

  describe "/survey/:survey_id :: show" do
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

      conn =
        conn
        |> assign(:current_user, Repo.get(User, 1234))

      conn = get conn, survey_path(conn, :show, 1)

      assert html_response(conn, 200) =~ "Assessment Questionaire"
    end
  end
end
