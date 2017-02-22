defmodule Skillswheel.Group do
  use Skillswheel.Web, :model

  schema "groups" do
    has_many :students, Skillswheel.Student
    field :group_name, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:group_name])
    |> validate_required([:group_name])
  end
end
