defmodule Skillswheel.Student do
  use Skillswheel.Web, :model

  schema "student" do
    belongs_to :group, Skillswheel.Group
    # has_many :survey, Skillswheel.Survey
    # field :group_id, :string
    field :student_name, :string
    field :student_sex, :string
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:student_name])
    |> validate_required([:student_name])
  end
end
