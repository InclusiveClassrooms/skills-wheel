defmodule Skillswheel.UserController do
  use Skillswheel.Web, :controller
  alias Skillswheel.User
  
  def new(conn, _params) do
    changeset = User.changeset(%User{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.registration_changeset(%User{}, user_params)
    case Repo.insert(changeset) do
    {:ok, user} ->
      conn
      |> Skillswheel.Auth.login(user)
      |> put_flash(:info, "#{user.name} created!")
      |> redirect(to: group_path(conn, :index))
    {:error, changeset} ->
      render conn, "new.html", changeset: changeset
    end
  end

end
