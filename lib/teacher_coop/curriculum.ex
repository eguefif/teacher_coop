defmodule TeacherCoop.Curriculum do
  @moduledoc """
  The curriculum is a set of learning objectives defines by a text.
  In our project, we work with the curriculum defined by France's Education Ministry.

  See [CurriculumScripts](../priv/curriculum/curriculum_populating.exs) for how we ingest the cuccirulum.
  """

  import Ecto.Query, warn: false
  alias TeacherCoop.Repo

  alias TeacherCoop.Curriculum.Objective
  alias TeacherCoop.Curriculum.Query
  alias TeacherCoop.Curriculum.FileIngestionWorker
  alias TeacherCoop.Curriculum.Ingestion

  @doc """
  Returns all the objectives from the Curriculum. 
  """
  @spec list_objectives!() :: [Objective.t() | term()]
  def list_objectives!() do
    Repo.all(Objective)
  end

  @doc """
  Returns all the objectives from the Curriculum by a key.
  """
  @spec list_objectives_by(keyword() | map()) :: [Objective.t() | term()]
  def list_objectives_by(clauses) do
    Repo.all_by(Objective, clauses)
  end

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
  Gets a single objective by a key.


  """
  @spec get_objective_by!(keyword() | map()) :: Objective.t() | term()
  def get_objective_by!(clause) do
    Repo.get_by!(Objective, clause)
  end

  @doc """
  Creates a objective.

  ## Examples

      iex> create_objective(scope, %{field: value})
      {:ok, %Objective{}}

      iex> create_objective(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_objective(map()) :: {:ok, Objective.t()} | {:error, Ecto.Changeset.t()}
  def create_objective(attrs) do
    with {:ok, objective = %Objective{}} <-
           %Objective{}
           |> Objective.changeset(attrs)
           |> Repo.insert() do
      {:ok, objective}
    end
  end

  @doc """
  Updates a objective.

  ## Examples

      iex> update_objective(ope, objective, %{field: new_value})
      {:ok, %Objective{}}

      iex> update_objective(ope, objective, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec update_objective(Objective.t(), map()) ::
          {:ok, Objective.t()} | {:error, Ecto.Changeset.t()}
  def update_objective(%Objective{} = objective, attrs) do
    with {:ok, objective = %Objective{}} <-
           objective
           |> Objective.changeset(attrs)
           |> Repo.update() do
      {:ok, objective}
    end
  end

  @doc """
  Deletes a objective.

  ## Examples

      iex> delete_objective(ope, objective)
      {:ok, %Objective{}}

      iex> delete_objective(scope, objective)
      {:error, %Ecto.Changeset{}}

  """
  @spec delete_objective(Objective.t()) ::
          {:ok, Objective.t()} | {:error, Ecto.Changeset.t()}
  def delete_objective(%Objective{} = objective) do
    with {:ok, objective = %Objective{}} <-
           Repo.delete(objective) do
      {:ok, objective}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking objective changes.

  ## Examples

      iex> change_objective(scope, objective)
      %Ecto.Changeset{data: %Objective{}}

  """
  def change_objective(%Objective{} = objective, attrs \\ %{}) do
    Objective.changeset(objective, attrs)
  end

  @doc """
  Bulk add a list of objectives from a file and metadata"
  """
  @spec bulk_add_objectives_from_file(integer(), map()) ::
          {:ok, Oban.Job.t()}
          | {:error_changeset, Ecto.Changeset.t()}
          | {:error, Oban.Job.changeset() | term()}
  def bulk_add_objectives_from_file(year, attrs) do
    changeset = Ingestion.changeset(%Ingestion{}, attrs)

    if changeset.valid? do
      %{attr: Map.put(changeset.changes, :year, year)}
      |> FileIngestionWorker.new()
      |> Oban.insert()
    else
      {:error_changeset, changeset}
    end
  end

  @doc """
  Return some statistics about the last curriculum.

  The returns is `[map()]`:
  level subject count of objectives
  """
  @spec get_stats(integer()) :: [map()]
  def get_stats(year) do
    Query.base()
    |> Query.where_year(year)
    |> Query.group_by_grade_and_subject()
    |> Repo.all()
  end
end
