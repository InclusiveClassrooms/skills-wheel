defmodule Skillswheel.TestHelpers do
  alias Skillswheel.{Repo, User, School}

  def insert_user(attrs \\ %{}) do
    changes = Map.merge(%{
      name: "user #{Base.encode16(:crypto.strong_rand_bytes(7))}",
      email: "random@test.com",
      password: "supersecret",
      school_id: 1
    }, attrs)

    %User{}
    |> User.registration_changeset(changes)
    |> Repo.insert!()
  end

  def insert_school() do
    %School{
      id: 1,
      name: "Test School",
      email_suffix: "test.com"
    } |> Repo.insert
  end
end
