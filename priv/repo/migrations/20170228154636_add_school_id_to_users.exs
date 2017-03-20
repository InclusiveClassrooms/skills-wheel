defmodule Skillswheel.Repo.Migrations.AddSchoolIdToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :school_id, references(:schools, on_delete: :delete_all)
    end
  end
end
