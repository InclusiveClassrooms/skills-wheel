defmodule Skillswheel.SessionController do
  use Skillswheel.Web, :controller
  alias Skillswheel.User

  def new(conn, _params) do
    registration_changeset = User.changeset(%User{})
    render conn, "new.html", layout: {Skillswheel.LayoutView, "login_layout.html"}, registration_changeset: registration_changeset
  end

  def create(conn, %{"session" => %{"email" => email, "password" => password}}) do
    case Skillswheel.Auth.login_by_email_and_pass(conn, email, password, repo: Repo) do
      {:ok, conn} ->
        conn
        |> put_flash(:info, "Welcome Back!")
        |> redirect(to: group_path(conn, :index))
      {:error, _reason, conn} ->
        conn
        |> put_flash(:error, "Invalid email/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _) do
    conn
    |> Skillswheel.Auth.logout()
    |> redirect(to: page_path(conn, :index))
  end

end
