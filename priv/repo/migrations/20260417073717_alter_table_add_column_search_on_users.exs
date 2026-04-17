defmodule TeacherCoop.Repo.Migrations.AlterTableAddColumnSearchOnUsers do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm;"

    execute """
      ALTER TABLE users
      ADD COLUMN search_text TEXT
      GENERATED ALWAYS AS (fullname || ' ' || email) STORED
    """

    execute "CREATE INDEX users_search_text_trgm_idx ON users USING GIN (search_text gin_trgm_ops)"
  end

  def down do
    execute "DROP EXTENSION IF EXISTS pg_trgm;"

    execute """
    ALTER TABLE users
    DROP COLUMN search_text;
    """

    execute "DROP INDEX IF EXISTS users_search_text_trgm_idx;"
  end
end
