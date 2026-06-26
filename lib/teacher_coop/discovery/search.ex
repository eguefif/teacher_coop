defmodule TeacherCoop.Discovery.Search do
  use Ecto.Schema
  import Ecto.Changeset

  schema "searches" do
    field :search_terms, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(search, attrs, user_scope) do
    search
    |> cast(attrs, [:search_terms])
    |> validate_required([:search_terms])
    |> put_change(:user_id, user_scope.user.id)
  end
end
