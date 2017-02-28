defmodule Skillswheel.TestHelpers do
  alias Skillswheel.Repo

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      name: "user #{Base.encode16(:crypto.rand_bytes(7))}",
      email: "random@user.com",
      password: "supersecret"
    }, attrs)

    %Skillswheel.User{}
    |> Skillswheel.User.registration_changeset(changes)
    |> Repo.insert!()
  end
end

