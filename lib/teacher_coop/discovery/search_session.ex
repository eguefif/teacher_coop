defmodule TeacherCoop.Discovery.SearchSession do
  @moduledoc """
  A `SearchSession` tracks a user over multiple searches.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias TeacherCoop.Discovery.Search
  alias TeacherCoop.Accounts.User

  schema "search_sessions" do
    field :state, :string
    field :timeout_at, :utc_datetime
    field :document_index, :string

    belongs_to(:user, User)
    has_many(:searches, Search)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(search, attrs, user_scope) when is_nil(user_scope) do
    permitted = [
      :state,
      :timeout_at,
      :document_index
    ]

    search
    |> cast(attrs, permitted)
    |> validate_required([])
  end

  @doc false
  def changeset(search, attrs, user_scope) do
    permitted = [
      :state,
      :timeout_at,
      :document_index
    ]

    search
    |> cast(attrs, permitted)
    |> validate_required([])
    |> put_change(:user_id, user_scope.user.id)
  end
end
