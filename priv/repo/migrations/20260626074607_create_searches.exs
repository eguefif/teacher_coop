defmodule TeacherCoop.Repo.Migrations.CreateSearches do
  use Ecto.Migration

  def change do
    create table(:searches) do
      add :search_terms, :string
      add :user_id, references(:users, on_delete: :delete_all)
      add :session_id, :string
      add :hits_count, :integer
      add :success, :boolean
      # What position was the success result in the ranking
      add :success_click_position, :integer
      add :dwell_time, :integer
      add :document_index, :string

      timestamps(type: :utc_datetime)
    end

    create index(:searches, [:user_id])
  end
end
