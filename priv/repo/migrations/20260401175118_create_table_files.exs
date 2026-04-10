defmodule TeacherCoop.Repo.Migrations.CreateTableFiles do
  use Ecto.Migration

  def change do
    create table("files") do
      add :filename, :string, null: false
      add :path, :string, null: false, size: 400
      add :format, :string, null: false, size: 30
      add :document_id, references("documents", on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
