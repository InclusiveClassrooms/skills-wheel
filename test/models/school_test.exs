defmodule Skillswheel.SchoolTest do
  use Skillswheel.ModelCase, async: false
  alias Skillswheel.School

  describe "School model" do
    @valid_attrs %{name: "Test", email_suffix: "test.org"}
    @invalid_attrs %{}

    test "changeset with correct attributes" do
      changeset = School.changeset(%School{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset with incorrect attributes" do
      changeset = School.changeset(%School{}, @invalid_attrs)
      refute changeset.valid?
    end
  end
end
