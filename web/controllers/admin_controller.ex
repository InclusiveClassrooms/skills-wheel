defmodule Skillswheel.AdminController do
  use Skillswheel.Web, :controller
  alias Skillswheel.School
  plug :authenticate_user when action in [:index]
  plug :authenticate_admin when action in [:index]


  def index(conn, _params) do
    schools = Repo.all(School)
    changeset = School.changeset(%School{})
    render conn, "index.html", changeset: changeset, schools: schools
  end
end
