defmodule Skillswheel.UserController do
  use Skillswheel.Web, :controller
  alias Skillswheel.User
  plug :authenticate_user when action in [:index, :show]
  # Need to discuss implementation of admin authentication
  # plug :authenticate_admin when action in [:index, :show, :create, :new]

  def index(conn, _params) do
    users = Repo.all(User)
    render conn, "index.html",  users: users
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get(User, id)

    render conn, "show.html", user: user
  end

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
      |> redirect(to: user_path(conn, :index))
    {:error, changeset} ->
      render conn, "new.html", changeset: changeset
    end
  end

end
