# Seed script for curriculum data.
#
# Reads curriculum files from priv/repo/curriculum/, parses them into structured
# entries, and performs two operations:
#   1. Populates the `curriculum_items` database table via Ecto (truncates first).
#   2. Indexes the entries into Meilisearch under the "curriculum" index.

import Ecto.Query, only: [from: 2]
alias TeacherCoop.Repo
alias TeacherCoop.Workspace.Curriculum.CurriculumItem

Dotenv.load()

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
    meili_master_key = Dotenv.get("MEILI_MASTER_KEY")
    meili_host = Dotenv.get("MEILISEARCH_HOST")
    Finch.start_link(name: :meili_finch)

    client =
      [endpoint: meili_host, key: meili_master_key, finch: :meili_finch]
      |> Meilisearch.Client.new()

    case Meilisearch.Index.get(client, "curriculum") do
      {:ok, _} ->
        {:ok, task} = Meilisearch.Index.delete(client, "curriculum")
        wait_for_task(client, task, "Delete index")

      {:error,
       %Meilisearch.Error{
         message: "Index `curriculum` not found.",
         link: "https://docs.meilisearch.com/errors#index_not_found",
         type: :invalid_request,
         code: :index_not_found
       }, 404} ->
        IO.puts("Index Curriculum not found")

      _ ->
        IO.puts("Error checking if index Curriculum exists")
    end

    {:ok, task} = Meilisearch.Index.create(client, %{uid: "curriculum", primaryKey: "id"})
    wait_for_task(client, task, "Create index")

    {:ok, task} = Meilisearch.Document.create_or_replace(client, "curriculum", entries)
    wait_for_task(client, task, "Add documents")
    IO.puts("Indexed curriculum into meilisearch")
  end

  defp wait_for_task(client, task, task_type) do
    {:ok, response} =
      Meilisearch.Task.get(client, task.taskUid)

    case Map.get(response, "status") do
      :enqueued ->
        Process.sleep(500)
        wait_for_task(client, task, task_type)

      :processing ->
        Process.sleep(500)
        wait_for_task(client, task, task_type)

      status ->
        IO.puts("Task " <> task_type <> " done with status #{status}")
    end
  end
end

IO.puts("\n************** Indexing Curriculum *********************\n")

entries =
  CurriculumFile.build_curriculum_files(base_path)
  |> Enum.flat_map(fn file -> CurriculumFile.parse_file(base_path, file) end)

Repo.insert_all(CurriculumItem, entries)

query =
  from c in CurriculumItem,
    select: %{id: c.id, strand: c.strand, grade: c.grade, item: c.item, subject: c.subject},
    where: c.year == 2024

entries = Repo.all(query)

CurriculumMeilisearch.index_entries(entries)
