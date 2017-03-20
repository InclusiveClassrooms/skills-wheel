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

  def format_class(score) do
    case score do
      "0" ->
        "never-previous"
      "1" ->
        "rarely-previous"
      "2" ->
        "sometimes-previous"
      "3" ->
        "always-previous"
    end
  end
end
