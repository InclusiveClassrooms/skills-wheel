defmodule Skillswheel.TestHelpers do
  alias Skillswheel.Repo

  def insert_user(attrs \\ %{}) do
    changes = Map.merge(%{
      name: "user #{Base.encode16(:crypto.strong_rand_bytes(7))}",
      email: "random@user.com",
      password: "supersecret"
    }, attrs)

    %Skillswheel.User{}
    |> Skillswheel.User.registration_changeset(changes)
    |> Repo.insert!()
  end
end

