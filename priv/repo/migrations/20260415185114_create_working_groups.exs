defmodule TeacherCoop.Repo.Migrations.CreateWorkingGroups do
  use Ecto.Migration

  def change do
    create table(:working_groups) do
      add :name, :string
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:working_groups, [:user_id])
  end
end
