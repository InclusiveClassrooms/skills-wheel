defmodule Skillswheel.Group do
  @moduledoc false
  use Skillswheel.Web, :model

  schema "groups" do
    field :name, :string
    many_to_many :users, Skillswheel.User, join_through: "users_groups"
    has_many :students, Skillswheel.Student

    timestamps()
  end

  def changeset(struct, params \\ :invalid) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end

  def invitation_changeset(struct, params \\ :invalid) do
    struct
    |> cast(params, [:email])
    |> validate_required([:email])
  end

end
