defmodule Skillswheel.StudentController do
  use Skillswheel.Web, :controller

  alias Skillswheel.{Student, Group, Survey}

  import Ecto.Query

  require IEx

  def create(conn, %{"student" => student}, _user) do
   group_id = student["group_id"]
   attrs
     =  student
     |> Map.new(fn {key, val} -> {String.to_atom(key), val} end)
     |> Map.delete(:group_id) 

    group = Repo.get!(Group, group_id)
    changeset = Ecto.build_assoc(group, :students) |> Student.changeset(attrs)

    case Repo.insert(changeset) do
      {:ok, _student} ->
        conn
        |> put_flash(:info, "Student created!")
        |> redirect(to: group_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Oops! All fields must be filled in to add a student!")
        |> redirect(to: group_path(conn, :index))
    end
  end

  def show(conn, %{"id" => student_id}, user) do
    user = Repo.preload(user, :groups)
    user_groups = Enum.map(user.groups, fn group -> group.id end)

    case Repo.get(Student, student_id) do
      nil ->
        conn
        |> put_flash(:error, "Student does not exist")
        |> redirect(to: group_path(conn, :index))
      student ->
        case Enum.member?(user_groups, student.group_id) do
          true ->

            surveys = Repo.all(
              from s in Survey,
              where: s.student_id == ^student_id,
              select: s
            )

            surveys
              =  surveys
              |> sanitize()

            student = Repo.preload(student, :group)
            render conn, "show.html", student: student, surveys: surveys
          _ ->
            conn
            |> put_flash(:error, "You do not have permission to view this student's profile")
            |> redirect(to: group_path(conn, :index))
        end
    end
  end

  defp sanitize(struct) do
    Enum.map(
      struct,
      fn survey ->
        survey
        |> Map.from_struct()
        |> Map.drop([:__meta__, :__struct__, :student])
      end
    )
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

  def post_pdf(conn, params, current_user) do
    IO.inspect params
    render conn, "post.json", key: "worlds"
  end

  def get_pdf(conn, params, current_user) do
    IO.inspect params
    render conn, "get.json", key: [%{"hello" => "world"}]
  end
end
