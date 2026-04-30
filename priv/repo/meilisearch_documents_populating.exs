defmodule Meilisearch.TeacherCoopDocuments do
  def populate() do
    if Meilisearch.Indexes.exists?("documents") == {:ok, false} do
      {:ok, _} = Meilisearch.Indexes.create("documents")
      IO.puts("Created index documents")
    end
  end
end

Meilisearch.TeacherCoopDocuments.populate()
