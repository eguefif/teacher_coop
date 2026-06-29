defmodule TeacherCoop.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :title, :string
      add :description, :string, size: 1500
      add :user_id, references(:users, on_delete: :delete_all)
      add :institution_type, :string

      timestamps(type: :utc_datetime)
    end

    create index(:documents, [:user_id])
  end
end
