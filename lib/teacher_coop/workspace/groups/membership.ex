defmodule TeacherCoop.Workspace.Groups.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  schema "memberships" do
    field :role, :string
    field :working_group_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(membership, attrs, group_id, user_id) do
    membership
    |> cast(attrs, [:role])
    |> validate_required([:role])
    |> put_change(:user_id, user_id)
    |> put_change(:working_group_id, group_id)
  end
end
