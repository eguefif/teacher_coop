defmodule TeacherCoop.WorkingGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "working_groups" do
    field :name, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(working_group, attrs, user_scope) do
    working_group
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> put_change(:user_id, user_scope.user.id)
  end
end
