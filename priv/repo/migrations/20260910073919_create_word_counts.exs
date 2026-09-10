defmodule TeacherCoop.Repo.Migrations.CreateWordCounts do
  use Ecto.Migration

  def change do
    create table(:word_counts) do
      add :word, :string
      add :count, :integer
      add :date, :date
    end

    create index(:word_counts, [:word])
    create index(:word_counts, [:date])
    create unique_index(:word_counts, [:word, :date])
  end
end
