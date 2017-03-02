defmodule Skillswheel.UserGroupTest do
  use Skillswheel.ModelCase
  alias Skillswheel.UserGroup

  @valid_attrs %{user_id: 1, group_id: 2}
  @invalid_attrs %{user_id: "", group_id: ""}

  test "changeset with correct attributes" do
    changeset = UserGroup.changeset(%UserGroup{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with incorrect attributes" do
    changeset = UserGroup.changeset(%UserGroup{}, @invalid_attrs)
    refute changeset.valid?
  end

end
