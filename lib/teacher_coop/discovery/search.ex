defmodule TeacherCoop.Discovery.Search do
  @moduledoc """
  A search is one query typed by the user on the search page.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias TeacherCoop.Discovery.SearchSession
  alias TeacherCoop.Accounts.User

  schema "searches" do
    field :search_terms, :string
    field :hits_count, :integer
    field :state, :string
    field :success_click_position, :integer
    field :dwell_time, :integer
    field :document_index, :string

    belongs_to(:user, User)
    belongs_to(:search_session, SearchSession)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(search, attrs, search_session, user_scope) do
    permitted = [
      :search_terms,
      :hits_count,
      :state,
      :success_click_position,
      :dwell_time,
      :document_index
    ]

    user_id = if user_scope, do: user_scope.user.id, else: nil
    search_session_id = if search_session, do: search_session.id, else: nil

    search
    |> cast(attrs, permitted)
    |> validate_required([:search_terms])
    |> put_change(:search_session_id, search_session_id)
    |> put_change(:user_id, user_id)
  end
end
