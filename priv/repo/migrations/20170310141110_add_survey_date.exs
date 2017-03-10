defmodule Skillswheel.Repo.Migrations.AddSurveyDate do
  use Ecto.Migration

  def change do
    alter table(:surveys) do
      timestamps()
    end

    create index(:surveys, [:student_id])
  end
end
