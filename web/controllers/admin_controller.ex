defmodule Skillswheel.AdminController do
  use Skillswheel.Web, :controller
  alias Skillswheel.School

  def index(conn, _params) do
    changeset = School.changeset(%School{})
    render conn, "index.html", changeset: changeset
  end
end
