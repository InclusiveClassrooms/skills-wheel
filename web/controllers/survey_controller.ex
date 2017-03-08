defmodule Skillswheel.SurveyController do
  use Skillswheel.Web, :controller

  alias Skillswheel.{Student, Survey}

  def create(conn, %{"survey" => survey}, _user) do
    IO.puts "++++++++++++++"
    IO.inspect survey
    IO.puts "++++++++++++++"

    student_id = survey["student_id"]
    attrs
      =  survey
      |> Map.new(fn {key, val} -> {String.to_atom(key), val} end)
      |> Map.delete(:student_id)
    student = Repo.get!(Student, student_id)
    changeset = Ecto.build_assoc(student, :surveys) |> Student.changeset(attrs)

    case Repo.insert(changeset) do
      {:ok, _student} ->
        handle_redirect(conn, :info, "Survey created!", student_id)
      {:error, _changeset} ->
        handle_redirect(conn, :error, "Error creating survey", student_id)
    end
  end

  defp handle_redirect(conn, flash, message, student_id) do
    conn
    |> put_flash(flash, message)
    |> redirect(to: student_path(conn, :show, student_id))
  end

  def show(conn, %{"id" => _student_id}, user) do
    render conn, "show.html"
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end
end
