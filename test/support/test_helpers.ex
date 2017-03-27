defmodule Skillswheel.TestHelpers do
  alias Skillswheel.{Repo, User, UserGroup, Group,
                     School, Student, Survey}
  alias Comeonin.Bcrypt

  @user_id 1
  @school_id 11
  @group_id 111
  @student_id 1111
  @survey_id 11111

  def id() do
    %{user: @user_id,
      school: @school_id,
      group: @group_id,
      student: @student_id,
      survey: @survey_id}
  end

  def insert_validated_user(attrs \\ %{}) do
    changes = Map.merge(
      %{name: "My Name",
        email: "email@test.com",
        password: "supersecret",
        school_id: @school_id,
        admin: false,
        id: @user_id},
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
    %{id: @user_id,
      name: "My Name",
      email: "email@test.com",
      password_hash: Bcrypt.hashpwsalt("password"),
      admin: false} |> insert(User, attrs)
  end

  def insert_school(attrs \\ %{}) do
    %{id: @school_id,
      name: "Test School",
      email_suffix: "test.com" } |> insert(School, attrs)
  end

  def insert_group(attrs \\ %{}) do
    %{id: @group_id, name: "Group #{@group_id}"} |> insert(Group, attrs)
  end

  def insert_student(attrs \\ %{}) do
    %{id: @student_id,
      first_name: "First",
      last_name: "Last",
      sex: "male",
      year_group: "1",
      group_id: @group_id} |> insert(Student, attrs)
  end

  def insert_usergroup(attrs \\ %{}) do
    %{user_id: @user_id, group_id: @group_id} |> insert(UserGroup, attrs)
  end

  def insert_survey(attrs \\ %{}) do
    Survey.elems
    |> Map.new(fn atom -> {atom, if atom == :student_id do @student_id else "1" end} end)
    |> insert(Survey, attrs)
  end
end
