defmodule Skillswheel.Repo.Migrations.AddTeachingAssistants do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :group_name, :string
    end
  end
end
