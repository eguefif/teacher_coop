defmodule TeacherCoop.Repo.Migrations.CreateObjectives do
  use Ecto.Migration

  # TODO: finish populating objectives
  # - [ ] Refactor objectives and remove user_id references
  # - [ ] Work on the whole script where we will save everything in the DB
  # - [ ] finish working on populate_objectves_index
  def change do
    create table(:objectives) do
      add :year, :integer
      add :subject, :string
      add :grade, :string
      add :goal, :string

      timestamps(type: :utc_datetime)
    end
  end
end
