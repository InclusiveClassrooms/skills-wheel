defmodule Skillswheel.SchoolController do
  use Skillswheel.Web, :controller
  alias Skillswheel.School

  def create(conn, %{"school" => school_params}) do
    changeset = School.changeset(%School{}, school_params)
    case Repo.insert(changeset) do
      {:ok, school} ->
        conn
        |> put_flash(:info, "School Created")
        |> redirect(to: admin_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Failed to create school")
        |> redirect(to: admin_path(conn, :index))
    end
  end
end
