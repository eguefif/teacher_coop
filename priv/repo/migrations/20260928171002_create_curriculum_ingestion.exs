defmodule TeacherCoop.Repo.Migrations.CreateCurriculumIngestion do
  use Ecto.Migration

  def change do
    create table(:curriculum_ingestions) do
      add :year, :integer
      add :subject, :string
      add :state, :string
      add :sentry_id, :string

      timestamps(type: :utc_datetime)
    end

    create index(:curriculum_ingestions, [:id])
  end
end
