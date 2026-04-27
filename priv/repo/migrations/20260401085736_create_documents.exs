defmodule TeacherCoop.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :title, :string
      add :description, :string, size: 1200
      add :public, :boolean, default: false
      add :tags, {:array, :text}, default: []
      add :goals, {:array, :text}, default: []
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:documents, [:user_id])
  end
end
