defmodule Skillswheel.GroupController do
  use Skillswheel.Web, :controller
  alias Skillswheel.{Group, Student, UserGroup}

  plug :authenticate_user when action in [:index, :create, :delete, :show]

  def index(conn, _params, user) do
    groups =
      Repo.all(user_groups(user))
      |> Repo.preload(:students)
      |> Repo.preload(:users)
    changeset =
      user
      |> build_assoc(:groups)
      |> Group.changeset()

    student_changeset = Student.changeset(%Student{})
    render conn, "index.html", changeset: changeset, groups: groups, student_changeset: student_changeset
  end

  def create(conn, %{"group" => group_params}, user) do
    changeset = Group.changeset(%Group{}, group_params)

    case Repo.insert(changeset) do
      {:ok, group} ->
        user_group_changeset = UserGroup.changeset(%UserGroup{}, %{
          user_id: user.id,
          group_id: group.id
          })
        case Repo.insert(user_group_changeset) do
          {:ok, _user_group} ->
            conn
            |> put_flash(:info, "Group created!")
            |> redirect(to: group_path(conn, :index))
          {:error, _changeset} ->
            conn
            |> put_flash(:error, "Error assigning group!")
            |> redirect(to: group_path(conn, :index))
        end
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Oops, the group name can't be empty!")
        |> redirect(to: group_path(conn, :index))
    end
  end

  def show(conn, %{"id" => group_id}, user) do

    case Repo.get(user_groups(user), group_id) do
      nil ->
        conn
        |> put_flash(:error, "Group does not exist")
        |> redirect(to: group_path(conn, :index))
      group ->
        students = Repo.all(group_students(group))
        changeset = Student.changeset(%Student{})
        render conn, "show.html", group: group, changeset: changeset, students: students
    end


  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end

  defp user_groups(user) do
    assoc(user, :groups)
  end

  defp group_students(group) do
    assoc(group, :students)
  end
end
