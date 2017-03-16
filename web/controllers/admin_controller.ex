defmodule Skillswheel.AdminController do
  use Skillswheel.Web, :controller
  alias Skillswheel.{School, Survey}
  plug :authenticate_user when action in [:index]
  plug :authenticate_admin when action in [:index]


  def index(conn, _params) do
    schools = Repo.all(School)
    changeset = School.changeset(%School{})

    survey_data = 
      [:teaching_assistant, :school, :student, :year, :group, :date]
      ++ List.delete(Survey.elems(), :student_id),
      fn q -> %{q => Atom.to_string(q) <> "1"} end
    ), 
    Enum.map(
      [:teaching_assistant, :school, :student, :year, :group, :date]
      ++ List.delete(Survey.elems(), :student_id),
      fn q -> %{q => Atom.to_string(q) <> "2"} end
    )]

    render conn, "index.html", changeset: changeset, schools: schools, survey_data: survey_data
  end
end
