defmodule Skillswheel.Student do
  @moduledoc false
  use Skillswheel.Web, :model

  alias Skillswheel.{Group, Survey}

  schema "students" do
    field :first_name, :string
    field :last_name, :string
    field :sex, :string
    field :year_group, :string
    belongs_to :group, Group
    has_many :surveys, Survey

    timestamps()
  end

  def changeset(struct, params \\ :invalid) do
    struct
    |> cast(params, [:first_name, :last_name, :sex, :year_group, :group_id])
    |> validate_required([:first_name, :last_name, :sex, :year_group, :group_id])
    |> assoc_constraint(:group)
  end
end
