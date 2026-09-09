defmodule TeacherCoop.Discovery.Search do
  @moduledoc """
  A search is one query typed by the user on the search page.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias TeacherCoop.Accounts.User

  schema "searches" do
    field :search_terms, :string
    field :hits_count, :integer
    field :state, :string
    field :success_click_position, :integer
    field :success_nature, :string
    field :dwell_time, :integer
    field :document_index, :string
    field :search_session_id, :string

    belongs_to(:user, User)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(search, attrs, user_scope) do
    permitted = [
      :search_terms,
      :hits_count,
      :state,
      :success_click_position,
      :dwell_time,
      :document_index,
      :success_nature,
      :search_session_id
    ]

    user_id = if user_scope, do: user_scope.user.id, else: nil

    search
    |> cast(attrs, permitted)
    |> validate_required([:search_terms])
    |> put_change(:user_id, user_id)
  end
end
