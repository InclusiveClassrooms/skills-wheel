defmodule Skillswheel.GroupTest do
  use Skillswheel.ModelCase, async: false

  alias Skillswheel.Group

  @valid_attrs %{name: "Test"}
  @invalid_attrs %{}

  test "changeset with correct attributes" do
    changeset = Group.changeset(%Group{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with incorrect attributes" do
    changeset = Group.changeset(%Group{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "group schema" do
    actual = Group.__schema__(:fields)
    expected = [:id, :name, :inserted_at, :updated_at]
    assert actual == expected
  end
end
