defmodule TeacherCoop.Repo.Migrations.CreateTableFiles do
  use Ecto.Migration

  def change do
    create table("files") do
      add :filename, :string, require: true
      add :path, :string, require: true, size: 400
      add :format, :string, require: true, size: 30
      add :type, :string, default: "none"
      add :document_id, references("documents", on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
