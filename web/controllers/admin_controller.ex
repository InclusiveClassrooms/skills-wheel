defmodule Skillswheel.AdminController do
  use Skillswheel.Web, :controller
  alias Skillswheel.{School, Survey}
  plug :authenticate_user when action in [:index]
  plug :authenticate_admin when action in [:index]

  # Takes a list of all scores in the form:
  # [[%{question: "...", answer: "1"}, ...],
  #  [%{question; "...", answer: "2"}, ...]
  #  ...
  # ]
  # And returns a list in the form:
  # [[%{"Self Awareness & Self-Esteem" => 12},
  #   %{"Managing Feelings" => 11},
  #   %{"Non-Verbal Communication" => 10},
  #   %{"Verbal Communication" => 4},
  #   %{"Planning & Problem Solving" => 14},
  #   %{"Relationships, Leaderships & Assertiveness" => 11}]
  #  ], ...
  # ]
  defp total_scores(surveys) do
    survey_titles = [
      "Self Awareness & Self-Esteem",
      "Managing Feelings",
      "Non-Verbal Communication",
      "Verbal Communication",
      "Planning & Problem Solving",
      "Relationships, Leaderships & Assertiveness"]

    surveys
    |> Enum.map(fn survey -> survey
      |> Map.new(fn {k, v} -> {k, String.to_integer v} end)
      |> Enum.reduce(
          [[]],
          fn (q, acc) ->
            if List.length(acc[List.length(acc) - 1]) === 5 do
              acc ++ [[q]]
            else
              acc
              |> Enum.with_index()
              |> Enum.map(fn {a, i} ->
                if i === a.length - 1 do
                  a[a.length - 1] ++ [q]
                else
                  a
                end
              end)
            end
          end
        )
      |> Enum.map(fn grouping ->
           Enum.reduce(grouping, 0, fn (n, acc) -> n + acc end)
         end)
    end)
  end

  def index(conn, _params) do
    schools = Repo.all(School)
    changeset = School.changeset(%School{})

    survey_data = [Enum.map(
      [:teaching_assistant, :school, :student, :year, :group, :date]
      ++ total_scores(Map.new(List.delete(Survey.elems(), :student_id),
      fn q -> %{q => Atom.to_string(q) <> "1"} end))
    ), 
    Enum.map(
      [:teaching_assistant, :school, :student, :year, :group, :date]
      ++ total_scores(List.delete(Survey.elems(), :student_id),
      fn q -> %{q => Atom.to_string(q) <> "2"} end)
    )]

    render conn, "index.html", changeset: changeset, schools: schools, survey_data: survey_data
  end
end
