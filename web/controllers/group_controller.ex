defmodule Skillswheel.GroupController do
  use Skillswheel.Web, :controller

  alias Skillswheel.Group

  def index(conn, _params) do
    changeset = Group.changeset(%Group{}, %{})
    groups = Repo.all(Group)

    render conn, "index.html", changeset: changeset, groups: groups
  end

  def create(conn, %{"group" => group}) do
    changeset = Group.changeset(%Group{}, group)

    case Repo.insert(changeset) do
      {:ok, _group} ->
        conn
        |> put_flash(:info, "Group Created")
        |> redirect(to: group_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Group Can't Be Blank")
        |> redirect(to: group_path(conn, :index))
    end
  end

  def show(conn, %{"group_id" => group_id}) do
    case Repo.get(Group, group_id) do
      nil ->
        conn
        |> put_flash(:error, "Group Does Not Exist")
        |> redirect(to: group_path(conn, :index))
      group ->
        render conn, "single.html", group: group
    end
  end
end
