defmodule Skillswheel.Repo.Migrations.AddStudents do
  use Ecto.Migration

  def change do
    create table(:students) do
      add :group_id, references(:groups)
      add :student_name, :string
      add :student_sex, :string
    end
  end
end
