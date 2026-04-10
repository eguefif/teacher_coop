defmodule TeacherCoop.Repo.Migrations.CreateCurriculumItems do
  use Ecto.Migration

  def change do
    create table(:curriculum_items) do
      add :year, :integer, null: false
      # Example: French, Mathematics, ...
      add :subject, :string, null: false
      # Example: writing, reading, ...
      add :strand, :string, require: false
      add :grade, :string, null: false
      add :item, :text, null: false

      timestamps()
    end
  end
end
