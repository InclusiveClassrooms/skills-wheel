defmodule Skillswheel.Repo.Migrations.AddIndexToUsers do
  use Ecto.Migration

  def change do
    create index(:users, [:school_id])
  end
end
