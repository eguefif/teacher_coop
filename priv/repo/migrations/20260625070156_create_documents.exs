defmodule TeacherCoop.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  # TODO: Work on objectives
  # - [ ] It should be a list of item
  # - [ ] Work on a autocomplete
  # - [ ] First implement a basic UI thing. Need the logic add objectives remove first.
  # - [ ] Add UI
  def change do
    create table(:documents) do
      add :title, :string
      add :description, :string, size: 1500
      add :user_id, references(:users, on_delete: :delete_all)
      add :institution_type, :string
      add :grade, :string
      add :objectives, {:array, :map}

      timestamps(type: :utc_datetime)
    end

    create index(:documents, [:user_id])
  end
end
