defmodule TeacherCoop.Curriculum.FileIngestionWorker do
  @moduledoc """
  Provide a Worker that will ingest a file to populate curriculum.
  """
  alias TeacherCoop.Curriculum

  use Oban.Worker,
    unique: true

  @doc """
  Perform a job that will do the ingestion.

  ## Attrs
    * `"year"` - The year when the curriculum was published
    * `"subject"` - The subject (french, maths, ...)
    * `"file_content"` - The file content
  """
  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    %{"year" => year, "subject" => subject, "file_content" => file_content} = args

    result =
      parse_file(year, subject, file_content)

    result =
      result
      |> Enum.map(&Curriculum.create_objective(&1))
      |> Enum.all?(&(elem(&1, 0) == :ok))

    case result do
      true -> :ok
      false -> :error
    end
  end

  @spec parse_file(integer(), String.t(), binary()) :: [map()]
  defp parse_file(year, subject, file_content) do
    common_data = %{year: year, subject: subject}

    file_content
    |> get_objectives()
    |> Enum.flat_map(& &1)
    |> Enum.map(&Map.merge(common_data, &1))
  end

  defp get_objectives(content) do
    content
    |> get_blocks()
    |> Enum.map(&parse_blocks(&1))
  end

  defp get_blocks(content) do
    String.split(content, "\n\n", trim: true)
  end

  def parse_blocks(block) do
    [first_line | lines] = String.split(block, "\n", trim: true)

    [strand, grade] = get_subject_and_grade(first_line)

    lines
    |> Enum.map(&%{strand: strand, grade: grade, goal: &1})
  end

  defp get_subject_and_grade(line) do
    String.split(line, "-", trim: true)
    |> Enum.map(&String.trim(&1))
  end
end
