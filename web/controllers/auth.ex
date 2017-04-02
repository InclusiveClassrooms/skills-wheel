defmodule Skillswheel.Auth do
  @moduledoc false
  import Plug.Conn
  import Comeonin.Bcrypt, only: [checkpw: 2, dummy_checkpw: 0]
  import Phoenix.Controller

  alias Skillswheel.{User, Router.Helpers}

  def init(opts) do
    Keyword.fetch!(opts, :repo)
  end

  def call(conn, repo) do
    user_id = get_session(conn, :user_id)

    cond do
      conn.assigns[:current_user] ->
        conn
      user = user_id && repo.get(User, user_id) ->
        assign(conn, :current_user, user)
      true ->
        assign(conn, :current_user, nil)
    end
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def login_by_email_and_pass(conn, email, given_pass, opts) do
    repo = Keyword.fetch!(opts, :repo)
    user = repo.get_by(User, email: email)

    cond do
      user && checkpw(given_pass, user.password_hash) ->
        {:ok, login(conn, user)}
      user ->
        {:error, :unauthorized, conn}
      true ->
        dummy_checkpw()
        {:error, :not_found, conn}
    end
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  defp authenticate(conn, type) do
    message = %{:user => "You must be logged in to view that page",
                :admin => "You don't have admin access"}

    if type == :user && conn.assigns.current_user
    || type == :admin && conn.assigns.current_user.admin do
        conn
    else
      conn
      |> put_flash(:error, message[type])
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end

  def authenticate_user(conn, _opts), do: conn |> authenticate(:user)
  def authenticate_admin(conn, _opts), do: conn |> authenticate(:admin)
end
