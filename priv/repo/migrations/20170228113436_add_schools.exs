defmodule Skillswheel.Repo.Migrations.AddSchools do
  use Ecto.Migration

  def change do
    create table(:schools) do
      add :name, :string, null: false
      add :email_suffix, :string, null: false

      timestamps()
    end
    create unique_index(:schools, [:name])
  end
end
