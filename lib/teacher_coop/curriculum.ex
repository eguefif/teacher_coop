defmodule TeacherCoop.Curriculum do
  @moduledoc """
  The curriculum is a set of learning objectives defined by a text.
  In our project, we work with the curriculum defined by France's Education Ministry.

  See `priv/curriculum/curriculum_populating.exs` for how we ingest the curriculum.
  """

  import Ecto.Query, warn: false
  alias TeacherCoop.Repo

  alias TeacherCoop.Accounts.Scope
  alias TeacherCoop.Curriculum.Objective
  alias TeacherCoop.Curriculum.Query
  alias TeacherCoop.Curriculum.FileIngestionWorker
  alias TeacherCoop.Curriculum.CurriculumIngestion
  alias TeacherCoop.Curriculum.CurriculumIngestionQuery

  # Objectives ******************************************************

  @doc """
  Returns all the objectives from the Curriculum.
  """
  @spec list_objectives!() :: [Objective.t() | term()]
  def list_objectives!() do
    Repo.all(Objective)
  end

  @doc """
  Returns all the objectives from the Curriculum matching the given clauses.
  """
  @spec list_objectives_by(keyword() | map()) :: [Objective.t() | term()]
  def list_objectives_by(clauses) do
    Repo.all_by(Objective, clauses)
  end

  @doc """
  Search objectives using the Search Engine.
  """
  @spec search_objectives(String.t()) ::
          [map()] | {:error, Meilisearch.Client.error()}
  def search_objectives(input) when is_bitstring(input) do
    TeacherCoop.SearchRepo.SearchObjectives.search(input)
  end

  @doc """
  Gets a single objective.

  Raises `Ecto.NoResultsError` if the Objective does not exist.

  ## Examples

      iex> get_objective!(123)
      %Objective{}

      iex> get_objective!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_objective!(integer()) :: Objective.t() | term()
  def get_objective!(id) do
    Repo.get_by!(Objective, id: id)
  end

  @doc """
  Gets a single objective matching the given clauses.

  Raises `Ecto.NoResultsError` if the Objective does not exist.
  """
  @spec get_objective_by!(keyword() | map()) :: Objective.t() | term()
  def get_objective_by!(clause) do
    Repo.get_by!(Objective, clause)
  end

  @doc """
  Creates an objective.

  ## Examples

      iex> create_objective(scope, %{field: value})
      {:ok, %Objective{}}

      iex> create_objective(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_objective(Scope.t(), map()) ::
          {:ok, Objective.t()} | {:error, Ecto.Changeset.t()}
  def create_objective(%Scope{} = scope, attrs) do
    true = Scope.is_admin?(scope)

    with {:ok, objective = %Objective{}} <-
           %Objective{}
           |> Objective.changeset(attrs)
           |> Repo.insert() do
      {:ok, objective}
    end
  end

  @doc """
  Creates objectives from a list in a single insert.

  Use `:bypass_auth` only in cases where you are sure a user cannot corrupt data, typically
  in a worker job scheduled by an admin user.

  ## Examples

      iex> create_objectives(scope, [%{field: value}])
      :ok

      iex> create_objectives(scope, [%{field: bad_value}])
      {:error, [%Ecto.Changeset{}]}

  """
  @spec create_objectives(Scope.t(), [map()]) ::
          :ok | {:error, [Ecto.Changeset.t()]}
  def create_objectives(%Scope{} = scope, attrs) do
    true = Scope.is_admin?(scope)
    do_create_objectives(attrs)
  end

  @spec create_objectives(:bypass_auth, [map()]) ::
          :ok | {:error, [Ecto.Changeset.t()]}
  def create_objectives(:bypass_auth, attrs) do
    do_create_objectives(attrs)
  end

  defp do_create_objectives(attrs) do
    with {:ok, _} <- validates_list_of_objectives(attrs) do
      attrs
      |> Enum.map(fn objective ->
        timestamp =
          DateTime.utc_now()
          |> DateTime.truncate(:second)

        Map.put(objective, :inserted_at, timestamp)
        |> Map.put(:updated_at, timestamp)
      end)
      |> then(
        &Repo.insert_all(Objective, &1,
          on_conflict: :nothing,
          conflict_target: [:grade, :goal]
        )
      )

      :ok
    end
  end

  @doc """
  Bulk creates a list of objectives from a file and metadata.
  """
  @spec bulk_create_objectives_from_files(Scope.t(), map(), String.t()) ::
          {:ok, Oban.Job.t()}
          | {:error_changeset, Ecto.Changeset.t()}
          | {:error, Oban.Job.changeset() | term()}
  def bulk_create_objectives_from_files(
        %Scope{} = scope,
        attrs,
        filecontent
      ) do
    true = Scope.is_admin?(scope)

    result = create_curriculum_ingestion(scope, attrs)

    case result do
      {:ok, curriculum_ingestion} ->
        year = curriculum_ingestion.year
        subject = curriculum_ingestion.subject
        id = curriculum_ingestion.id

        %{ingestion_id: id, year: year, subject: subject, filecontent: filecontent}
        |> FileIngestionWorker.new()
        |> Oban.insert()

      {:error, changeset} ->
        {:error_changeset, changeset}
    end
  end

  @spec validates_list_of_objectives([map()]) :: {:ok | :error, [Ecto.Changeset.t()]}
  defp validates_list_of_objectives(attrs) do
    changesets = attrs |> Enum.map(&Objective.changeset(%Objective{}, &1))
    is_valid? = if Enum.all?(changesets, &(&1.valid? == true)), do: :ok, else: :error

    {is_valid?, changesets}
  end

  @doc """
  Updates an objective.

  ## Examples

      iex> update_objective(scope, objective, %{field: new_value})
      {:ok, %Objective{}}

      iex> update_objective(scope, objective, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_objective(Scope.t(), Objective.t(), map()) ::
          {:ok, Objective.t()} | {:error, Ecto.Changeset.t()}
  def update_objective(%Scope{} = scope, %Objective{} = objective, attrs) do
    true = Scope.is_admin?(scope)

    with {:ok, objective = %Objective{}} <-
           objective
           |> Objective.changeset(attrs)
           |> Repo.update() do
      {:ok, objective}
    end
  end

  @doc """
  Deletes an objective.

  ## Examples

      iex> delete_objective(scope, objective)
      {:ok, %Objective{}}

      iex> delete_objective(scope, objective)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_objective(Scope.t(), Objective.t()) ::
          {:ok, Objective.t()} | {:error, Ecto.Changeset.t()}
  def delete_objective(%Scope{} = scope, %Objective{} = objective) do
    true = Scope.is_admin?(scope)

    with {:ok, objective = %Objective{}} <-
           Repo.delete(objective) do
      {:ok, objective}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking objective changes.

  ## Examples

      iex> change_objective(objective)
      %Ecto.Changeset{data: %Objective{}}

  """
  def change_objective(%Objective{} = objective, attrs \\ %{}) do
    Objective.changeset(objective, attrs)
  end

  # CurriculumIngestion related logic ************************************************

  @doc """
  Subscribes to notifications about any curriculum ingestion changes.

  The broadcasted messages match the pattern:

    * :ingestion_updated

  """
  @spec subscribe_curriculum_ingestions() :: :ok | {:error, term()}
  def subscribe_curriculum_ingestions() do
    Phoenix.PubSub.subscribe(TeacherCoop.PubSub, ":curriculum_ingestions")
  end

  @spec broadcast_curriculum_ingestions(:ingestion_updated) :: :ok | {:error, term()}
  defp broadcast_curriculum_ingestions(message) do
    Phoenix.PubSub.broadcast(TeacherCoop.PubSub, ":curriculum_ingestions", message)
  end

  @doc """
  Gets a curriculum ingestion.

  Use `:bypass_auth` only in cases where you are sure a user cannot corrupt data, typically
  in a worker job scheduled by an admin user.
  """
  @spec get_curriculum_ingestion(Scope.t(), integer()) :: CurriculumIngestion.t() | nil
  def get_curriculum_ingestion(%Scope{} = scope, id) do
    true = Scope.is_admin?(scope)
    Repo.get(CurriculumIngestion, id)
  end

  @spec get_curriculum_ingestion(:bypass_auth, integer()) :: CurriculumIngestion.t() | nil
  def get_curriculum_ingestion(:bypass_auth, id) do
    Repo.get(CurriculumIngestion, id)
  end

  @doc """
  Creates a curriculum ingestion.
  """
  @spec create_curriculum_ingestion(Scope.t(), map()) ::
          {:ok, CurriculumIngestion.t()} | {:error, Ecto.Changeset.t()}
  def create_curriculum_ingestion(%Scope{} = scope, attrs) do
    true = Scope.is_admin?(scope)

    CurriculumIngestion.changeset(%CurriculumIngestion{}, attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a curriculum ingestion.

  Use `:bypass_auth` only in cases where you are sure a user cannot corrupt data, typically
  in a worker job scheduled by an admin user.
  """
  @spec update_curriculum_ingestion(Scope.t(), CurriculumIngestion.t(), map()) ::
          {:ok, CurriculumIngestion.t()} | {:error, Ecto.Changeset.t()}
  def update_curriculum_ingestion(%Scope{} = scope, ingestion, attrs) do
    true = Scope.is_admin?(scope)
    do_update_curriculum_ingestion(ingestion, attrs)
  end

  @spec update_curriculum_ingestion(:bypass_auth, CurriculumIngestion.t(), map()) ::
          {:ok, CurriculumIngestion.t()} | {:error, Ecto.Changeset.t()}
  def update_curriculum_ingestion(:bypass_auth, ingestion, attrs) do
    do_update_curriculum_ingestion(ingestion, attrs)
  end

  defp do_update_curriculum_ingestion(ingestion, attrs) do
    with {:ok, ingestion} <-
           CurriculumIngestion.changeset(ingestion, attrs)
           |> Repo.update() do
      broadcast_curriculum_ingestions(:ingestion_updated)
      {:ok, ingestion}
    end
  end

  @doc """
  Returns the number of objectives per grade and subject for the given year.

  Each entry is a map like `%{grade: "cp", subject: "français", count: 42}`.
  """
  @spec get_stats(Scope.t(), integer()) :: [map()]
  def get_stats(%Scope{} = scope, year) do
    true = Scope.is_admin?(scope)

    Query.base()
    |> Query.where_year(year)
    |> Query.group_by_grade_and_subject()
    |> Repo.all()
  end

  @doc """
  Returns the last n ingestions.
  """
  @spec list_last_ingestions(Scope.t(), integer()) :: [CurriculumIngestion.t()]
  def list_last_ingestions(%Scope{} = scope, n) do
    true = Scope.is_admin?(scope)

    CurriculumIngestionQuery.base()
    |> CurriculumIngestionQuery.last_n_entries(n)
    |> Repo.all()
  end
end
