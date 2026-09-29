defmodule TeacherCoop.Curriculum.FileIngestionWorker do
  @moduledoc """
  Provide a Worker that will ingest a file to populate curriculum.

  It populate objectives table.
  Index objectives index in the search engine.
  Update curriculum_ingestion depending on the result.
  """
  alias TeacherCoop.Curriculum
  alias TeacherCoop.SearchRepo.SearchObjectives

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

    ingestion = Curriculum.get_curriculum_ingestion(ingestion_id)

    with attrs <- parse_file(year, subject, filecontent),
         {:ok, objectives} <- create_objectives(attrs),
         :ok <- index_search_database(objectives),
         {:ok, _} <- update_ingestion_to_finished(ingestion) do
      :ok
    else
      {:error_db, changesets} ->
        log_sentry(
          "Error while inserting in DB objectives from ingestion",
          changesets,
          ingestion
        )

        {:error, :db}

      {:error_ingestion, changeset} ->
        log_sentry(
          "Error while updating ingestion object",
          changeset,
          ingestion
        )

        {:error, :update_ingestion}

      :error_indexing ->
        log_sentry(
          "Error while indexing objectives in search engine from ingestion.",
          nil,
          ingestion
        )

        {:error, :indexing}
    end
  end

  @spec update_ingestion_to_finished(Curriculum.CurriculumIngestion.t()) ::
          {:ok, Curriculum.CurriculumIngestion.t()} | {:error_ingestion, Ecto.Changeset.t()}
  defp update_ingestion_to_finished(ingestion) do
    case(Curriculum.update_curriculum_ingestion(ingestion, %{state: "finished"})) do
      {:ok, ingestion} -> {:ok, ingestion}
      {:error, changeset} -> {:error_ingestion, changeset}
    end
  end

  @spec create_objectives([map()]) ::
          {:ok, [Curriculum.CurriculumIngestion.t()]} | {:error_db, [Ecto.Changeset.t()]}
  defp create_objectives(data) do
    db_results =
      data
      |> Enum.map(&Curriculum.create_objective(&1))

    case Enum.all?(db_results, &(elem(&1, 0) == :ok)) do
      true -> {:ok, db_results}
      false -> {:error_db, db_results}
    end
  end

  @spec index_search_database([Curriculum.CurriculumIngestion.t()]) :: :ok | :error_indexing
  defp index_search_database(attrs) do
    with :ok <- SearchObjectives.reset_objectives_index(),
         attrs <- preprocess_objectives(attrs),
         :ok <-
           SearchObjectives.populate_objectives_index(attrs) do
      :ok
    else
      :error -> :error_indexing
    end
  end

  @spec preprocess_objectives([Curriculum.CurriculumIngestion.t()]) :: [map()]
  defp preprocess_objectives(attrs) do
    attrs
    |> Enum.map(&elem(&1, 1))
    |> Enum.map(&Map.take(&1, [:id, :year, :subject, :grade, :strand, :goal]))
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

  @spec log_sentry(
          String.t(),
          list(map())
          | list(Ecto.Changeset.t())
          | Ecto.Changeset.t()
          | nil,
          Curriculum.CurriculumIngestion.t()
        ) :: {:ok, Curriculum.CurriculumIngestion.t()}
  defp(log_sentry(msg, changesets, ingestion)) do
    result =
      Sentry.capture_message(msg,
        extra: %{
          ingestion: ingestion.id,
          errors: get_error(changesets)
        }
      )

    sentry_id = if result != :ignored, do: elem(result, 1), else: nil

    Curriculum.update_curriculum_ingestion(ingestion, %{
      state: "error",
      sentry_id: sentry_id
    })
  end

  defp get_error(error) when is_nil(error) do
    ""
  end

  defp get_error(result) when is_map(result) do
    result
  end

  defp get_error(results) when is_list(results) do
    Enum.map(results, fn {status, changeset} ->
      if status == :error do
        Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
          Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
            opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
          end)
        end)
        |> Map.values()
        |> Enum.at(0)
        |> Enum.take(5)
      end
    end)
    |> Enum.filter(&(is_nil(&1) != true))
    |> List.flatten()
    |> Enum.uniq()
  end
end
