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
    * `"filecontent"` - The file content
  """
  @impl Oban.Worker
  def perform(%Oban.Job{args: args}) do
    %{
      "ingestion_id" => ingestion_id,
      "year" => year,
      "subject" => subject,
      "filecontent" => filecontent
    } = args

    result =
      parse_file(year, subject, filecontent)

    results =
      result
      |> Enum.map(&Curriculum.create_objective(&1))

    is_success? =
      results
      |> Enum.all?(&(elem(&1, 0) == :ok))

    ingestion = Curriculum.get_curriculum_ingestion(ingestion_id)

    case is_success? do
      true ->
        {:ok, _} = Curriculum.update_curriculum_ingestion(ingestion, %{state: "finished"})
        :ok

      false ->
        result =
          Sentry.capture_message("Curriculum ingestion failed",
            extra: %{
              ingestion: ingestion_id,
              errors: get_error(results) |> Enum.take(5)
            }
          )

        sentry_id = if result != :ignored, do: elem(result, 1), else: nil

        {:ok, _} =
          Curriculum.update_curriculum_ingestion(ingestion, %{
            state: "error",
            sentry_id: sentry_id
          })

        {:error, sentry_id}
    end
  end

  defp get_error(results) do
    Enum.map(results, fn {status, changeset} ->
      if status == :error do
        Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
          Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
            opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
          end)
        end)
        |> Map.values()
        |> Enum.at(0)
      end
    end)
    |> Enum.filter(&(is_nil(&1) != true))
    |> List.flatten()
    |> Enum.uniq()
    |> IO.inspect()
  end

  @spec parse_file(integer(), String.t(), binary()) :: [map()]
  defp parse_file(year, subject, filecontent) do
    common_data = %{year: year, subject: subject}

    filecontent
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
