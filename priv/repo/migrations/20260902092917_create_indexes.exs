defmodule TeacherCoop.Repo.Migrations.CreateIndexes do
  use Ecto.Migration

  def change do
    create table(:indexes) do
      add :name, :string
      add :primary_key, :string
      add :type, :string
      add :state, :string
      add :task_uid, :string
      add :engine_configuration_id, references(:engine_configurations, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:indexes, [:user_id])

    create index(:indexes, [:engine_configuration_id])
  end
end
