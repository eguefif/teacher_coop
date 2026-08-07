defmodule TeacherCoop.Discovery.Search do
  use Ecto.Schema
  import Ecto.Changeset

  schema "searches" do
    field :search_terms, :string
    field :user_id, :id
    field :session_id, :integer
    field :hits_count, :integer
    field :success, :boolean
    # What position was the success result in the ranking
    field :success_click_position, :integer
    field :dwell_time, :integer
    field :document_index, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(search, attrs, user_scope) when is_nil(user_scope) do
    permitted = [
      :search_terms,
      :hits_count,
      :success,
      :success_click_position,
      :dwell_time,
      :document_index
    ]

    search
    |> cast(attrs, permitted)
    |> validate_required([:search_terms])
  end

  @doc false
  def changeset(search, attrs, user_scope) do
    search
    |> cast(attrs, [:search_terms])
    |> validate_required([:search_terms])
    |> put_change(:user_id, user_scope.user.id)
  end
end
