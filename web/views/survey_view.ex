defmodule Skillswheel.SurveyView do
  use Skillswheel.Web, :view

  def get_int_string(tuple) do
    (elem(tuple, 1) + 1)
    |> Integer.to_string
  end

  def atom_title(section) do
    elem(section, 0).title
    |> String.replace(" ", "-")
    |> String.to_atom()
  end
end
