defmodule Skillswheel.StudentController do
  use Skillswheel.Web, :controller

  alias Skillswheel.{User, UserGroup, School, Student, Group, Survey, RedisCli, LayoutView}

  require IEx

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

  def post_file(conn, %{"_json" => html, "survey_id" => survey_id}, _current_user) do
    survey = Repo.get_by(Survey, id: survey_id)
    date = Integer.to_string(survey.inserted_at.month) <> "/" <> String.slice(Integer.to_string(survey.inserted_at.year), 2, 4)
    student = Repo.get(Student, survey.student_id)
    name = student.first_name <> student.last_name
    year = student.year_group
    group = Repo.get(Group, student.group_id)
    group_name = group.name
    user_id = Repo.get_by(UserGroup, group_id: group.id).user_id
    user = Repo.get(User, user_id)
    user_name = user.name || "Unknown name"
    school_name = user.school_id && Repo.get(School, user.school_id).name || "Admin School"

    rand_wheel = "skills_wheel_" <> gen_rand_string(12) <> ".pdf"
    link_changed_html = String.replace(html, "/images",
      if (System.get_env("MIX_ENV") == "prod") do
        IO.puts "MIX ENV PROD"
        "https://skillswheel.herokuapp.com/images"
      else
        IO.puts "MIX ENV NOT PROD"
        "http://localhost:4000/images"
      end)

    user_name = "user name"

    form_data = [%{label: "Teaching Assistant:", name: user_name},
    %{label: "Student:", name: name},
    %{label: "School:", name: school_name},
    %{label: "School Year:", name: year},
    %{label: "Group:", name: group_name},
    %{label: "Date:", name: date}]
    form_string
      =  form_data
      |> Enum.map(fn (data) -> "<div style=\"margin: 5px\"><h4>" <> data.label <> "</h4><h4><strong>" <> data.name <> "</strong></h4></div>" end)
      |> Enum.join("")

    pdf_binary = PdfGenerator.generate_binary!("
      <html>
        <head>
          <link href=\"https://fonts.googleapis.com/css?family=Open+Sans:700\" rel=\"stylesheet\" type=\"text/css\"><link href=\"https://fonts.googleapis.com/css?family=Varela+Round\" rel=\"stylesheet\" type=\"text/css\">
        </head>
        <body>
          <header style=\"background-color: #E5007D; width: 100%; height: 4em;\">
            <a href=\"http://inclusiveclassrooms.co.uk\">
              <img src=\""
                <>
                  if (System.get_env("MIX_ENV") == "prod") do
                    IO.puts "MIX ENV PROD"
                    "https://skillswheel.herokuapp.com/images/inclusive-classrooms-300x126.png"
                  else
                    IO.puts "MIX ENV NOT PROD"
                    "http://localhost:4000/images/inclusive-classrooms-300x126.png"
                  end
                <>
              "\" alt=\"inclusive classrooms\" height=\"100%\"/>
            </a>
          </header>
          <div style='float: left'>"
            <> form_string <>
          "</div>
          <div style='float: right'>"
            <> link_changed_html <>
          "</div>
        </body>
      </html>",
      shell_params: ["--orientation", "Landscape"]
    )
    RedisCli.set(rand_wheel, pdf_binary)
    RedisCli.expire(rand_wheel, 60 * 60)
    render conn, "post.json", link: rand_wheel
  end

  def get_file(conn, %{"file_id" => file}, _current_user) do
    case RedisCli.get(file) do
      {:ok, nil} ->
        contents = PdfGenerator.generate_binary!("<html><body><h1> Download Link has Expired </h1><h3> Please try again </h3></body></html>")
        render conn, "get.pdf", contents: contents, layout: {LayoutView, "simple.pdf"}
      {:ok, f} -> 
        render conn, "get.pdf", contents: f, layout: {LayoutView, "simple.pdf"}
    end
  end
end
