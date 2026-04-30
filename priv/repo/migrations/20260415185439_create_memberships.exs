defmodule TeacherCoop.Repo.Migrations.CreateMemberships do
  use Ecto.Migration

  def change do
    create table(:memberships) do
      add :role, :string
      add :working_group_id, references(:working_groups, on_delete: :nothing)
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:memberships, [:user_id])
    create index(:memberships, [:working_group_id])
    create unique_index(:memberships, [:working_group_id, :user_id])
  end
end
