defmodule Skillswheel.SchoolController do
  use Skillswheel.Web, :controller
  alias Skillswheel.School

  plug :authenticate_user when action in [:create, :delete]
  plug :authenticate_admin when action in [:create, :delete]

  def create(conn, %{"school" => school_params}) do
    changeset = School.changeset(%School{}, school_params)
    case Repo.insert(changeset) do
      {:ok, school} ->
        conn
        |> put_flash(:info, "#{school.name} Created")
        |> redirect(to: admin_path(conn, :index))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Failed to create school")
        |> redirect(to: admin_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => school_id}) do
    school = Repo.get(School, school_id)
    case Repo.delete school do
      {:ok, _struct}       ->
        conn
        |> put_flash(:info, "#{school.name} deleted!")
        |> redirect(to: admin_path(conn, :index))
    end
  end
end
