defmodule Skillswheel.SurveyTest do
  use Skillswheel.ModelCase, async: false

  alias Skillswheel.Survey

  @valid_attrs Survey.elems() |> Map.new(fn atom ->
    {atom, if atom == :student_id do 1 else "string" end}
  end)

  @invalid_attrs %{}

  test "changeset with correct attributes" do
    changeset = Survey.changeset(%Survey{}, @valid_attrs)

    assert changeset.valid?
  end

  test "changeset with incorrect attributes" do
    changeset = Survey.changeset(%Survey{}, @invalid_attrs)

    refute changeset.valid?
  end

  test "survey schema" do
    actual = Survey.__schema__(:fields)
    expected = [:id] ++ Survey.elems ++ [:inserted_at, :updated_at]

    assert actual == expected
  end
end
