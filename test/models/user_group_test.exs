defmodule Skillswheel.UserGroupTest do
  use Skillswheel.ModelCase, async: false
  alias Skillswheel.UserGroup

  @valid_attrs %{user_id: 1, group_id: 2}
  @invalid_attrs %{}

  test "changeset with correct attributes" do
    changeset = UserGroup.changeset(%UserGroup{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with incorrect attributes" do
    changeset = UserGroup.changeset(%UserGroup{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "user schema" do
    actual = UserGroup.__schema__(:fields)
    expected = [:user_id, :group_id]

    assert actual == expected
  end
end
