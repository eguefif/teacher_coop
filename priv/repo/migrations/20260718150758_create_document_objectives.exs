defmodule TeacherCoop.Repo.Migrations.CreateDocumentObjectives do
  use Ecto.Migration

  def change do
    create table(:document_objectives) do
      add :document_id, references(:documents, on_delete: :nothing)
      add :objective_id, references(:objectives, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:document_objectives, [:document_id])
    create index(:document_objectives, [:objective_id])
    create unique_index(:document_objectives, [:document_id, :objective_id])
  end
end
