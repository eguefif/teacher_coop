defmodule TeacherCoop.Curriculum do
  @moduledoc """
  The Curriculum context.
  """

  import Ecto.Query, warn: false
  alias TeacherCoop.Repo

  alias TeacherCoop.Curriculum.Objective
  alias TeacherCoop.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any objective changes.

  The broadcasted messages match the pattern:

    * {:created, %Objective{}}
    * {:updated, %Objective{}}
    * {:deleted, %Objective{}}

  """
  def subscribe_objectives(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(TeacherCoop.PubSub, "user:#{key}:objectives")
  end

  defp broadcast_objective(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(TeacherCoop.PubSub, "user:#{key}:objectives", message)
  end

  @doc """
  Returns the list of objectives.

  ## Examples

      iex> list_objectives(scope)
      [%Objective{}, ...]

  """
  def list_objectives(%Scope{} = scope) do
    Repo.all_by(Objective, user_id: scope.user.id)
  end

  @doc """
  Gets a single objective.

  Raises `Ecto.NoResultsError` if the Objective does not exist.

  ## Examples

      iex> get_objective!(scope, 123)
      %Objective{}

      iex> get_objective!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_objective!(%Scope{} = scope, id) do
    Repo.get_by!(Objective, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a objective.

  ## Examples

      iex> create_objective(scope, %{field: value})
      {:ok, %Objective{}}

      iex> create_objective(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_objective(%Scope{} = scope, attrs) do
    with {:ok, objective = %Objective{}} <-
           %Objective{}
           |> Objective.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_objective(scope, {:created, objective})
      {:ok, objective}
    end
  end

  @doc """
  Updates a objective.

  ## Examples

      iex> update_objective(scope, objective, %{field: new_value})
      {:ok, %Objective{}}

      iex> update_objective(scope, objective, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_objective(%Scope{} = scope, %Objective{} = objective, attrs) do
    true = objective.user_id == scope.user.id

    with {:ok, objective = %Objective{}} <-
           objective
           |> Objective.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_objective(scope, {:updated, objective})
      {:ok, objective}
    end
  end

  @doc """
  Deletes a objective.

  ## Examples

      iex> delete_objective(scope, objective)
      {:ok, %Objective{}}

      iex> delete_objective(scope, objective)
      {:error, %Ecto.Changeset{}}

  """
  def delete_objective(%Scope{} = scope, %Objective{} = objective) do
    true = objective.user_id == scope.user.id

    with {:ok, objective = %Objective{}} <-
           Repo.delete(objective) do
      broadcast_objective(scope, {:deleted, objective})
      {:ok, objective}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking objective changes.

  ## Examples

      iex> change_objective(scope, objective)
      %Ecto.Changeset{data: %Objective{}}

  """
  def change_objective(%Scope{} = scope, %Objective{} = objective, attrs \\ %{}) do
    true = objective.user_id == scope.user.id

    Objective.changeset(objective, attrs, scope)
  end
end
