defmodule Skillswheel.SchoolTest do
  use Skillswheel.ModelCase

  alias Skillswheel.School

  @valid_attrs %{name: "Test", email_suffix: "test.org"}
  @invalid_attrs %{name: "", email_suffix: ""}

  test "changeset with correct attributes" do
    changeset = School.changeset(%School{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with incorrect attributes" do
    changeset = School.changeset(%School{}, @invalid_attrs)
    refute changeset.valid?
  end
end
