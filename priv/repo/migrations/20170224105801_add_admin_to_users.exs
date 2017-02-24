defmodule Skillswheel.Repo.Migrations.AddAdminToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :admin, :boolean
    end
  end
end
