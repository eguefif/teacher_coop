defmodule TeacherCoop.Repo.Migrations.CreateCurriculumItems do
  use Ecto.Migration

  def change do
    create table(:curriculum_items) do
      add :year, :integer, null: false
      # Example: French, Mathematics, ...
      add :subject, :string, null: false, size: 20
      # Example: writing, reading, ...
      add :strand, :string, null: true, size: 75
      add :grade, :string, null: false, size: 20
      add :item, :string, null: false, size: 250

      timestamps(type: :utc_datetime)
    end
  end
end
