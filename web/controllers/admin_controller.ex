defmodule Skillswheel.AdminController do
  use Skillswheel.Web, :controller
  alias Skillswheel.{School, Survey, Student, Group, User, UserGroup}

  plug :authenticate_user when action in [:index]
  plug :authenticate_admin when action in [:index]

  def all_survey_data() do
    Repo.all(Survey)
    |> Enum.map(fn survey ->
      naive = survey.inserted_at
      date = Integer.to_string(naive.day) <>
      "/" <> Integer.to_string(naive.month) <>
      "/" <> String.slice(Integer.to_string(naive.year), 2..3)

      student = Repo.get(Student, survey.student_id)
      year = student.year_group
      name = student.first_name <> " " <> student.last_name
      group = Repo.get(Group, student.group_id)
      group_name = group.name
      user = Repo.get(User, Repo.get_by(UserGroup, group_id: group.id).user_id)
      ta = user.name
      school = user.school_id
        && Repo.get(School, user.school_id).name
        || "Admin School"

      survey_data = survey
      |> Map.from_struct
      |> Map.drop([:updated_at, :inserted_at, :student,
                   :__meta__, :student_id, :id])
      |> Enum.map(fn {k, v} -> {k, String.to_integer(v)} end)

      ordered_survey = Survey.elems
      |> List.delete(:student_id)
      |> Enum.map(fn question -> survey_data[question] end)
      |> Enum.chunk(5)
      |> Enum.map(fn chunk -> Enum.sum(chunk) end)

      survey_titles = [
        "Self Awareness & Self-Esteem",
        "Managing Feelings",
        "Non-Verbal Communication",
        "Verbal Communication",
        "Planning & Problem Solving",
        "Relationships, Leaderships & Assertiveness",
        "Survey Total"]

      Enum.zip(survey_titles, ordered_survey ++ [Enum.sum(ordered_survey)])
      |> Map.new
      |> Map.merge(%{"Date" => date, "Year" => year, "Child Name" => name,
                     "Group Name" => group_name, "Teaching Assistant" => ta, "School Name" => school})
    end)
  end

  def index(conn, _params) do
    schools = Repo.all(School)
    changeset = School.changeset(%School{})
    surveys = all_survey_data()

    render conn, "index.html", changeset: changeset, schools: schools, surveys: surveys
  end
end
