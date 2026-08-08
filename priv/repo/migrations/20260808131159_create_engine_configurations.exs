defmodule TeacherCoop.Repo.Migrations.CreateEngineConfigurations do
  use Ecto.Migration

  def change do
    create table(:engine_configurations) do
      add :engine, :string
      add :config, :map
      add :index_name, :string
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:engine_configurations, [:user_id])
  end
end
