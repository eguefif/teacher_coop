defmodule TeacherCoop.Repo.Migrations.CreateObjectives do
  use Ecto.Migration

  def change do
    create table(:objectives) do
      add :year, :integer
      add :subject, :string
      add :strand, :string
      add :grade, :string
      add :goal, :string, size: 500

      timestamps(type: :utc_datetime)
    end
  end
end
