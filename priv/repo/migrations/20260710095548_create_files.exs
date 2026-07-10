defmodule TeacherCoop.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:files) do
      add :filename, :string
      add :format, :string
      add :filepath, :string
      add :document_id, references(:documents, on_delete: :nullify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:files, [:user_id])
  end
end
