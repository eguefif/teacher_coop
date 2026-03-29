defmodule TeacherCoop.Repo.Migrations.AlterTableAddFullname do
  use Ecto.Migration

  def change do
    alter table("users") do
      add :fullname, :string, size: 160
    end
  end
end
