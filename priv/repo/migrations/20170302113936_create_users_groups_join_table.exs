defmodule Skillswheel.Repo.Migrations.CreateUsersGroupsJoinTable do
  use Ecto.Migration

  def change do
    create table(:users_groups, primary_key: false) do
      add :user_id, references(:users)
      add :group_id, references(:groups)
    end
  end
end
