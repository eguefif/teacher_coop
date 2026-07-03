defmodule TeacherCoop.Curriculum do
  @moduledoc """
  The Curriculum context.
  """

  import Ecto.Query, warn: false
  alias TeacherCoop.Repo

  alias TeacherCoop.Curriculum.Objective

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
  def get_objective!(id) do
    Repo.get_by!(Objective, id: id)
  end

  @doc """
  Creates a objective.

  ## Examples

      iex> create_objective(scope, %{field: value})
      {:ok, %Objective{}}

      iex> create_objective(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
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
end
