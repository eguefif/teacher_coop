defmodule TeacherCoop.TeacherCoop.Discovery.SearchSession do
  use Ecto.Schema
  import Ecto.Changeset

  schema "search_sessions" do
    field :state, :string
    field :index, :string
    field :timeout_at, :utc_datetime
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(search_session, attrs, user_scope) do
    search_session
    |> cast(attrs, [:state, :index, :timeout_at])
    |> validate_required([:state, :index, :timeout_at])
    |> put_change(:user_id, user_scope.user.id)
  end
end
