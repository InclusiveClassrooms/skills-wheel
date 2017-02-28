defmodule Skillswheel.School do
  use Skillswheel.Web, :model

  schema "schools" do
    field :name, :string
    field :email_suffix, :string

    timestamps()
  end

  def changeset(struct, params \\ :invalid) do
    struct
    |> cast(params, [:email_suffix, :name])
    |> validate_required([:email_suffix, :name])
    |> unique_constraint(:name)
  end
end
