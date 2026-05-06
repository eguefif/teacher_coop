defmodule TeacherCoop.Repo.Migrations.CreateWorkingGroups do
  use Ecto.Migration

  def change do
    create table(:working_groups) do
      add :name, :string, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
