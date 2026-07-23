# Seed script for curriculum data.
# Note that we ingest items from the 2024 curriculum.
#
# Reads curriculum files from priv/repo/curriculum/, parses them into structured
# entries, and performs two operations:
#   1. Populates the `curriculum_items` database table via Ecto (truncates first).
#   2. Indexes the entries into Meilisearch under the "curriculum" index.

import Ecto.Query, only: [from: 2]
alias TeacherCoop.Repo
alias TeacherCoop.Curriculum.Objective

Dotenv.load()

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

  @doc """
  Returns a list of files from a base path.
  It follows every possible directory to get all the files
  """
  def build_curriculum_files(path) do
    case File.dir?(path) do
      false ->
        [path]

      true ->
        File.ls!(path)
        |> Enum.flat_map(fn entry -> build_curriculum_files(path <> "/" <> entry) end)
    end
  end

  @doc """
  Parse a file and returns a list of Maps.
  """
  def parse_file(base_path, file) do
    [year | rest] =
      String.replace(file, base_path, "")
      |> Path.split()
      |> Enum.drop(1)

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
            goal: String.trim(entry.goal),
            inserted_at: date_time,
            updated_at: date_time
          }
        end)
    end
  end

  def parse_block(block) do
    [first_line | rest] = String.split(block, "\n", trim: true)
    [strand, grade] = String.split(first_line, "-", trim: true)

    Enum.map(rest, fn entry -> %{strand: strand, grade: grade, goal: entry} end)
  end
end

IO.puts("\n************** Populating Curriculum *********************\n")

TeacherCoop.SearchRepo.SearchObjectives.reset_objectives_index()

{:ok, cwd} = File.cwd()
base_path = Path.join(cwd, "/priv/curriculum/curriculum/")

entries =
  CurriculumFile.build_curriculum_files(base_path)
  |> Enum.flat_map(fn file -> CurriculumFile.parse_file(base_path, file) end)

Repo.insert_all(Objective, entries)

query =
  from c in Objective,
    select: %{
      id: c.id,
      strand: c.strand,
      grade: c.grade,
      goal: c.goal,
      subject: c.subject,
      year: c.year
    },
    where: c.year == 2024

entries = Repo.all(query)

TeacherCoop.SearchRepo.SearchObjectives.populate_objectives_index(entries)
