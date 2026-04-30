# Seed script for curriculum data.
#
# Reads curriculum files from priv/repo/curriculum/, parses them into structured
# entries, and performs two operations:
#   1. Populates the `curriculum_items` database table via Ecto (truncates first).
#   2. Indexes the entries into Meilisearch under the "curriculum" index.

import Ecto.Query, only: [from: 2]
alias TeacherCoop.Repo
alias TeacherCoop.Workspace.Curriculum.CurriculumItem

{:ok, _} = Repo.query("TRUNCATE curriculum_items", [])

{:ok, cwd} = File.cwd()
base_path = Path.join(cwd, "/priv/repo/curriculum/")

defmodule CurriculumFile do
  @moduledoc """
  This module contains utilities function to seed the database with curriculum entries.  
  It uses the content of curriculum/ to find relevant files, parse them and seed the database.
  The curriculum forlder is organize per year/school_level/subject.

  Each file are organized as follow:
  * Section are separated by a double line feed.
  * One section has a one-line header formated as: strand - LEVEL (lecture - CP)
  * Each following lines are a curriculum entry for that section.
  """
  defstruct year: 0, subject: "", content: ""

  def build_curriculum_files(path) do
    case File.dir?(path) do
      false ->
        [path]

      true ->
        File.ls!(path)
        |> Enum.flat_map(fn entry -> build_curriculum_files(path <> "/" <> entry) end)
    end
  end

  def parse_file(base_path, file) do
    [year | rest] =
      String.replace(file, base_path, "")
      |> Path.split()
      |> Enum.slice(1..-1//1)

    subject = List.last(rest) |> Path.rootname()
    content = File.read!(file)
    year = String.to_integer(year)
    date_time = DateTime.utc_now() |> DateTime.truncate(:second)

    case content do
      "" ->
        []

      _ ->
        String.split(content, "\n\n", trim: true)
        |> Enum.flat_map(&parse_block/1)
        |> Enum.map(fn entry ->
          %{
            year: year,
            subject: String.trim(subject),
            strand: String.trim(entry.strand),
            grade: String.trim(entry.grade),
            item: String.trim(entry.item),
            inserted_at: date_time,
            updated_at: date_time
          }
        end)
    end
  end

  def parse_block(block) do
    [first_line | rest] = String.split(block, "\n", trim: true)
    [strand, grade] = String.split(first_line, "-", trim: true)

    Enum.map(rest, fn entry -> %{strand: strand, grade: grade, item: entry} end)
  end
end

defmodule CurriculumMeilisearch do
  @moduledoc """
  This modules contains utility functions to index curriculum into Meilisearch
  """

  def index_entries(entries) do
    if Meilisearch.Indexes.exists?("curriculum") == {:ok, false} do
      {:ok, task} = Meilisearch.Indexes.delete("curriculum")
      wait_for_task(task, "Delete index")
      {:ok, task} = Meilisearch.Indexes.create("curriculum")
      wait_for_task(task, "Create index")
    end

    {:ok, task} = Meilisearch.Documents.add_or_replace("curriculum", entries)
    wait_for_task(task, "Add documents")
    IO.inspect(task)
    IO.puts("Indexed curriculum into meilisearch")
  end

  defp wait_for_task(task, task_type) do
    {:ok, response} =
      Meilisearch.HTTP.get("/tasks/" <> Integer.to_string(Map.get(task, "taskUid")))

    task_status = response.body

    case Map.get(task_status, "status") do
      "enqueued" -> Process.sleep(500)
      "processing" -> Process.sleep(500)
      status -> IO.puts("Task " <> task_type <> " done with status " <> status)
    end
  end
end

entries =
  CurriculumFile.build_curriculum_files(base_path)
  |> Enum.flat_map(fn file -> CurriculumFile.parse_file(base_path, file) end)

Repo.insert_all(CurriculumItem, entries)

query =
  from c in CurriculumItem,
    select: %{id: c.id, strand: c.strand, grade: c.grade, item: c.item, subject: c.subject},
    where: c.year == 2024

CurriculumMeilisearch.index_entries(entries)
