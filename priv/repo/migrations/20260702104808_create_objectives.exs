defmodule TeacherCoop.Repo.Migrations.CreateObjectives do
  use Ecto.Migration

  def change do
    create table(:objectives) do
      add :year, :integer
      add :subject, :string
      add :grade, :string
      add :goal, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:objectives, [:user_id])
  end
end
