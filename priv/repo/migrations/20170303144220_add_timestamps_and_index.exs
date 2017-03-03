defmodule Skillswheel.Repo.Migrations.AddTimestampsAndIndex do
  use Ecto.Migration

  def change do
    alter table(:students) do
      timestamps()
    end

    create index(:students, [:group_id])
  end
end
