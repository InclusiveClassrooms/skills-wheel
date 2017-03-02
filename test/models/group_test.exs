defmodule Skillswheel.GroupTest do
  use Skillswheel.ModelCase
  alias Skillswheel.Group

  @valid_attrs %{name: "Test"}
  @invalid_attrs %{name: ""}

  test "changeset with correct attributes" do
    changeset = Group.changeset(%Group{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with incorrect attributes" do
    changeset = Group.changeset(%Group{}, @invalid_attrs)
    refute changeset.valid?
  end
end
