defmodule Skillswheel.School do
  use Skillswheel.Web, :model

  schema "schools" do
    field :name, :string
    field :email_suffix, :string
    has_many :users, Skillswheel.User

    timestamps()
  end

  def changeset(struct, params \\ :invalid) do
    struct
    |> cast(params, [:email_suffix, :name])
    |> validate_required([:email_suffix, :name])
    |> unique_constraint(:name)
  end

  def alphabetical(query) do
    from s in query, order_by: s.name
  end

  def names_and_ids(query) do
    from s in query, select: {s.name, s.id}
  end
end
