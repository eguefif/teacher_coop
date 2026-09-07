defmodule TeacherCoop.Repo.Migrations.CreateSearchSessions do
  use Ecto.Migration

  def change do
    create table(:search_sessions) do
      add :state, :string
      add :document_index, :string
      add :timeout_at, :utc_datetime
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:search_sessions, [:user_id])
  end
end
