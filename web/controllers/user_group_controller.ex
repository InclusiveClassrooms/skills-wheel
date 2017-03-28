defmodule Skillswheel.UserGroupController do
  use Skillswheel.Web, :controller
  alias Skillswheel.UserGroup

  plug :authenticate_user when action in [:delete]

  def delete(conn, %{"id" => group_id, "user_params" => %{"user_id" => user_id}}, _user) do
    Repo.delete_all(from u in UserGroup,
    where: (u.user_id == ^user_id and u.group_id == ^group_id))
    conn
    |> redirect(to: group_path(conn, :show, group_id))
  end

  def action(conn, _) do
    apply(__MODULE__, action_name(conn),
          [conn, conn.params, conn.assigns.current_user])
  end
end
