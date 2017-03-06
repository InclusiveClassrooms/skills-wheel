defmodule Skillswheel.StudentTest do
   use Skillswheel.ModelCase, async: false
   alias Skillswheel.{Group, Student}

   setup do
     %Group{
       name: "Test Group",
       id: 7
     } |> Repo.insert
     :ok
   end

   @valid_attrs %{
     first_name: "First",
     last_name: "Last",
     sex: "female",
     year_group: "4",
     group_id: 7
   }
   @invalid_attrs %{first_name: "", last_name: "", sex: "", year_group: "", group_id: ""}

   test "changeset with valid attributes" do
     changeset = Student.changeset(%Student{}, @valid_attrs)
     assert changeset.valid?
   end

   test "changeset with invalid attributes" do
     changeset = Student.changeset(%Student{}, @invalid_attrs)
     refute changeset.valid?
   end

  test "student schema" do
    actual = Student.__schema__(:fields)
    expected = [:id, :first_name, :last_name, :sex, :year_group, :group_id, :inserted_at, :updated_at]

    assert actual == expected
  end
end
