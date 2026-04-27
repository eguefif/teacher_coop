defmodule TeacherCoop.Repo.Migrations.CreateConnection do
  use Ecto.Migration

  def change do
    create table(:connections) do
      add :user1_id, references(:users, on_delete: :nothing)
      add :user2_id, references(:users, on_delete: :nothing)
      add :state, :string

      timestamps(type: :utc_datetime)
    end

    create index(:connections, [:user1_id, :user2_id])
    create index(:connections, [:user2_id, :user1_id])

    create constraint(:connections, "user1 must be different than user2",
             check: "user1_id <> user2_id"
           )
  end
end
