defmodule Skillswheel.Repo.Migrations.AddStudents do
  use Ecto.Migration

  def change do
    create table(:students) do
      add :first_name, :string
      add :last_name, :string
      add :sex, :string
      add :year_group, :string
      add :group_id, references(:groups)
    end
  end
end
