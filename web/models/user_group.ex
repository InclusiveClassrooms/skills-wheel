defmodule Skillswheel.UserGroup do
  use Skillswheel.Web, :model

  @primary_key false
  schema "users_groups" do
    belongs_to :user, Skillswheel.User
    belongs_to :group, Skillswheel.Group
  end

  def changeset(struct, params \\ :invalid) do
    struct
    |> cast(params, [:user_id, :group_id])
    |> validate_required([:user_id, :group_id])
  end
end
