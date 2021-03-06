defmodule Skillswheel.SurveyControllerTest do
  use Skillswheel.ConnCase
  import Mock

  alias Skillswheel.{User, Student, Group, Survey}

  describe "/survey :: create_survey" do
    test "Successful new survey", %{conn: conn} do
      with_mock HTTPotion, [post: fn(_url) -> nil end] do
        insert_user()
        insert_group()
        insert_usergroup()

        group = Repo.get!(Group, id().group)
        changeset = Ecto.build_assoc(group, :students)
          |> Student.changeset(%{
            first_name: "First",
            last_name: "Last",
            sex: "male",
            year_group: "5",
            group_id: id().group
          })

        {:ok, student} = changeset |> Repo.insert
        conn = post conn, survey_path(conn, :create_survey, student.id),
          %{"survey" => Map.new(Survey.elems, fn atom -> {atom, Atom.to_string(atom)} end)}

        assert redirected_to(conn, 302) == "/students/" <> Integer.to_string(student.id)
        assert get_flash(conn, :info) == "Survey submitted"
      end
    end

    test "Unsuccessful survey request", %{conn: conn} do
      with_mock HTTPotion, [post: fn(_url) -> nil end] do
        insert_school()
        insert_user(%{admin: true, school_id: id().school})
        insert_group()
        insert_usergroup()

        group = Repo.get!(Group, id().group)
        changeset = Ecto.build_assoc(group, :students)
          |> Student.changeset(%{
            first_name: "First",
            last_name: "Last",
            sex: "male",
            year_group: "5",
            group_id: id().group
          })
        {:ok, student} = changeset |> Repo.insert

        conn = post conn, survey_path(conn, :create_survey, student.id),
          %{"survey" => Map.new(Survey.elems, fn atom -> {atom, ""} end)}
        assert redirected_to(conn, 302) == "/students/" <> Integer.to_string(student.id)
        assert get_flash(conn, :error) == "Error creating survey"
      end
    end
  end

  describe "/survey/:student_id :: show" do
    test "shows the form", %{conn: conn} do
      insert_user()
      insert_group()
      insert_usergroup()
      insert_student()
      insert_survey()

      conn = assign(conn, :current_user, Repo.get(User, id().user))
      conn = get conn, survey_path(conn, :show, id().student)

      assert html_response(conn, 200) =~ "Assessment Questionaire"
    end

    test "unknown student id redirects back to groups", %{conn: conn} do
      insert_user()

      conn = assign(conn, :current_user, Repo.get(User, id().user))
      conn = get conn, survey_path(conn, :show, id().student)

      assert redirected_to(conn, 302) =~ "/groups"
    end

    test "known student which is not yours redirects back to groups" , %{conn: conn} do
      insert_user()
      insert_group()
      insert_group(%{id: id().group + 1, name: "Test Group #{id().group + 1}"})
      insert_usergroup()
      insert_student()
      insert_student(%{id: id().student + 1, group_id: id().group + 1})

      conn = assign(conn, :current_user, Repo.get(User, id().user))
      conn = get conn, survey_path(conn, :show, id().group + 1)

      assert redirected_to(conn, 302) =~ "/groups"
    end
  end
end
