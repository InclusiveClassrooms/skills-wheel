defmodule Skillswheel.StudentController do
  use Skillswheel.Web, :controller

  alias Skillswheel.{Student, Group, Survey, RedisCli}

  import Ecto.Query

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

  defp gen_rand_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64()
    |> binary_part(0, length)
  end

  def post_file(conn, %{"_json" => html, "survey_id" => _survey_id}, _current_user) do
    rand_wheel = "skills_wheel_" <> gen_rand_string(12) <> ".pdf"
    link_changed_html = String.replace(html, "/images", "http://localhost:4000/images")
    pdf_binary = PdfGenerator.generate_binary!("<html><body><h1>Hello World</h1><div style='float: right'>" <> link_changed_html <> "</div></body></html>", page_size: "A6", shell_params: ["--orientation", "Landscape"])
    RedisCli.set(rand_wheel, pdf_binary)
    RedisCli.expire(rand_wheel, 60 * 60)
    render conn, "post.json", link: rand_wheel
  end

  def get_file(conn, %{"file_id" => file}, _current_user) do
    case RedisCli.get(file) do
      {:ok, nil} ->
        contents = PdfGenerator.generate_binary!("<html><body><h1> Download Link has Expired </h1><h3> Please try again </h3></body></html>")
        render conn, "get.pdf", contents: contents, layout: {Skillswheel.LayoutView, "simple.pdf"}
      {:ok, f} -> 
        render conn, "get.pdf", contents: f, layout: {Skillswheel.LayoutView, "simple.pdf"}
    end
  end
end
