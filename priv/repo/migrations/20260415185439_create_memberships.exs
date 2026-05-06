defmodule TeacherCoop.Repo.Migrations.CreateMemberships do
  use Ecto.Migration

  def change do
    create table(:memberships) do
      add :role, :string, size: 25, null: false
      add :working_group_id, references(:working_groups, on_delete: :nothing), null: false
      add :user_id, references(:users, type: :id, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:memberships, [:user_id])
    create index(:memberships, [:working_group_id])
    create unique_index(:memberships, [:working_group_id, :user_id])
  end
end
