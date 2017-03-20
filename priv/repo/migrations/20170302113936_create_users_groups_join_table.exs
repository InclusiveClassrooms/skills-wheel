defmodule Skillswheel.Repo.Migrations.CreateUsersGroupsJoinTable do
  use Ecto.Migration

  def change do
    create table(:users_groups, primary_key: false) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :group_id, references(:groups, on_delete: :delete_all)
    end
  end
end
