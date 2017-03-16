defmodule Skillswheel.GroupController do
  use Skillswheel.Web, :controller
  alias Skillswheel.{Group, Student, UserGroup, User}

  plug :authenticate_user when action in [:index, :create, :delete, :show, :update]

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
        group =
          group
          |> Repo.preload(:users)
        changeset = Group.changeset(group)
        invitation_changeset = Group.invitation_changeset(%User{})
        render conn, "show.html", layout: {Skillswheel.LayoutView, "edit_group_layout.html"}, group: group, changeset: changeset, invitation_changeset: invitation_changeset
    end
  end

  def update(conn, %{"id" => group_id, "group" => group_params}, user) do
    group = Repo.get!(user_groups(user), group_id)
    changeset = Group.changeset(group, group_params)
    case Repo.update(changeset) do
      {:ok, group} ->
        conn
        |> put_flash(:info, "Group name updated!")
        |> redirect(to: group_path(conn, :show, group.id))
      {:error, changeset} ->
        render conn, "show.html", group: group, changeset: changeset
    end
  end

  def invite(conn, params = %{"email_params" => %{"email" => email}, "group_id" => group_id}, user) do
    case Repo.get_by(User, email: email) do
      nil ->
        conn
        |> put_flash(:error, "This person has not registered with Skillswheel yet")
        |> redirect(to: group_path(conn, :show, group_id))
      user ->
        case Repo.all(
          from u in UserGroup,
          where: u.group_id == ^group_id and u.user_id == ^user.id,
          select: u
        ) do
          [] ->
            user_group_changeset = UserGroup.changeset(%UserGroup{}, %{
              user_id: user.id,
              group_id: group_id
              })
            case Repo.insert(user_group_changeset) do
              {:ok, _user_group} ->
                conn
                |> put_flash(:info, "#{user.name} added to the group!")
                |> redirect(to: group_path(conn, :show, group_id))
              {:error, _changeset} ->
                conn
                |> put_flash(:error, "Error adding #{user.name} to the group!")
                |> redirect(to: group_path(conn, :show, group_id))
            end
          _more ->
            conn
            |> put_flash(:error, "#{user.name} already added to the group!")
            |> redirect(to: group_path(conn, :show, group_id))
        end

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
