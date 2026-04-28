defmodule TeacherCoop.Repo.Migrations.CreateTableDocumentsWorkingGroups do
  use Ecto.Migration

  def change do
    create table(:documents_working_groups) do
      add :document_id, references(:documents, on_delete: :delete_all)
      add :working_group_id, references(:working_groups, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create unique_index(:documents_working_groups, [:document_id, :working_group_id])
  end
end
