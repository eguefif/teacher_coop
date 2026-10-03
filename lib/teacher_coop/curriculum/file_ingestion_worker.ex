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

    ingestion = Curriculum.get_curriculum_ingestion(:bypass_auth, ingestion_id)

    with attrs <- parse_file(year, subject, filecontent),
         :ok <- create_objectives(attrs),
         :ok <- index_search_database(),
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
    case(Curriculum.update_curriculum_ingestion(:bypass_auth, ingestion, %{state: "finished"})) do
      {:ok, ingestion} -> {:ok, ingestion}
      {:error, changeset} -> {:error_ingestion, changeset}
    end
  end

  @spec create_objectives([map()]) ::
          :ok | {:error_db, [Ecto.Changeset.t()]}
  defp create_objectives(data) do
    # Safety: we can use bypass auth, the job is scheduled by an admin.
    db_results = Curriculum.create_objectives(:bypass_auth, data)

    case db_results do
      :ok -> :ok
      {:error, changesets} -> {:error_db, changesets}
    end
  end

  @spec index_search_database() :: :ok | :error_indexing
  defp index_search_database() do
    objectives = Curriculum.list_objectives!()

    with attrs <- preprocess_objectives(objectives),
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

  defp parse_blocks(block) do
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

    Curriculum.update_curriculum_ingestion(:bypass_auth, ingestion, %{
      state: "error",
      sentry_id: sentry_id
    })
  end

  defp get_error(error) when is_nil(error) do
    ""
  end

  defp get_error(changeset) when is_map(changeset) do
    changeset_to_string(changeset)
  end

  defp get_error(changesets) when is_list(changesets) do
    Enum.map(changesets, fn changeset ->
      changeset_to_string(changeset)
    end)
    |> Enum.filter(&(&1 != nil))
    |> Enum.take(10)
  end

  defp changeset_to_string(%Ecto.Changeset{} = changeset) do
    error_string = changeset_error_to_string(changeset)
    changes_string = changeset_changes_to_string(changeset.changes)
    error_string <> " for changes: " <> changes_string
  end

  defp changeset_error_to_string(%Ecto.Changeset{} = changeset) do
    changeset
    |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
    |> Enum.map_join("; ", fn {field, msgs} -> "#{field}: #{Enum.join(msgs, ", ")}" end)
  end

  defp changeset_changes_to_string(changes) do
    changes
    |> Map.to_list()
    |> Enum.map(&tupple_to_string(&1))
    |> Enum.join(" ")
  end

  defp tupple_to_string({key, value}) do
    "{Key: " <> to_string(key) <> ": " <> to_string(value) <> "}"
  end
end
