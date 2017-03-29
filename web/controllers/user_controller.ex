defmodule Skillswheel.UserController do
  use Skillswheel.Web, :controller
  alias Skillswheel.{User, Auth}

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
    {:ok, user} ->
      conn
      |> Auth.login(user)
      |> put_flash(:info, "#{user.name} created!")
      |> redirect(to: group_path(conn, :index))
    {:error, _changeset} ->
      conn
      |> put_flash(:error, "Error signing up!")
      |> redirect(to: session_path(conn, :new))
    end
  end
end
