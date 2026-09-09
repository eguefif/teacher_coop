defmodule TeacherCoop.Repo.Migrations.CreateSearches do
  use Ecto.Migration

  def change do
    create table(:searches) do
      add :search_terms, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :search_session_id, :string
      add :hits_count, :integer
      add :success_click_position, :integer
      add :success_nature, :string
      add :dwell_time, :integer
      add :document_index, :string
      add :state, :string

      timestamps(type: :utc_datetime)
    end

    create index(:searches, [:user_id])
  end
end
