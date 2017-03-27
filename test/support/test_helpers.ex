defmodule Skillswheel.TestHelpers do
  alias Skillswheel.{Repo, User, UserGroup, Group,
                     School, Student, Survey}
  alias Comeonin.Bcrypt

  def insert_validated_user(attrs \\ %{}) do
    changes = Map.merge(
      %{name: "My Name",
        email: "email@test.com",
        password: "supersecret",
        school_id: 1,
        admin: false},
        attrs)

    %User{}
    |> User.registration_changeset(changes)
    |> Repo.insert!
  end

  defp insert(map, data_struct, attrs) do
    changes = Map.merge(map, attrs)

    struct(data_struct, changes) |> Repo.insert!
  end

  def insert_user(attrs \\ %{}) do
    %{id: 1,
      name: "My Name",
      email: "email@test.com",
      password_hash: Bcrypt.hashpwsalt("password"),
      admin: false} |> insert(User, attrs)
  end

  def insert_school(attrs \\ %{}) do
    %{id: 1,
      name: "Test School",
      email_suffix: "test.com" } |> insert(School, attrs)
  end

  def insert_group(attrs \\ %{}) do
    %{id: 1, name: "Group 1"} |> insert(Group, attrs)
  end

  def insert_student(attrs \\ %{}) do
    %{id: 1,
      first_name: "First",
      last_name: "Last",
      sex: "male",
      year_group: "1",
      group_id: 1} |> insert(Student, attrs)
  end

  def insert_usergroup(attrs \\ %{}) do
    %{user_id: 1, group_id: 1} |> insert(UserGroup, attrs)
  end

  def insert_survey(attrs \\ %{}) do
    Survey.elems
    |> Map.new(fn atom -> {atom, if atom == :student_id do 1 else "1" end} end)
    |> insert(Survey, attrs)
  end
end
