defmodule TeacherCoop.Groups.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  schema "memberships" do
    field :role, :string
    field :working_group_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(membership, attrs, group, user_scope) do
    membership
    |> cast(attrs, [:role])
    |> validate_required([:role])
    |> put_change(:user_id, user_scope.user.id)
    |> put_change(:working_group_id, group.id)
  end
end
