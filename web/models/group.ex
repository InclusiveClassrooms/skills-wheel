defmodule Skillswheel.Group do
  use Skillswheel.Web, :model

  schema "groups" do
    field :name, :string
    many_to_many :users, Skillswheel.User, join_through: "users_groups"

    timestamps()
  end

  def changeset(struct, params \\ :invalid) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
