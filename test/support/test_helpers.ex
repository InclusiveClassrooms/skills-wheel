defmodule Skillswheel.TestHelpers do
  alias Skillswheel.Repo

  def insert_user(attrs \\ %{}) do
    changes = Map.merge(%{
      name: "user #{Base.encode16(:crypto.strong_rand_bytes(7))}",
      email: "random@test.com",
      password: "supersecret",
      school_id: 1
    }, attrs)

    %Skillswheel.User{}
    |> Skillswheel.User.registration_changeset(changes)
    |> Repo.insert!()
  end

  def insert_group(id, name) do
    %Skillswheel.Group{
      name: name,
      id: id
    } |> Repo.insert
    :ok
  end
end
