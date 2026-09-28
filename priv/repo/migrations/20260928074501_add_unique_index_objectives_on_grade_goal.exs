defmodule TeacherCoop.Repo.Migrations.AddUniqueIndexObjectivesOnGradeGoal do
  use Ecto.Migration

  def change do
    create unique_index(:objectives, [:grade, :goal])
  end
end
