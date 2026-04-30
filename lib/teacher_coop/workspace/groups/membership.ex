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
  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:role, :working_group_id, :user_id])
    |> validate_required([:role, :working_group_id, :user_id])
    |> unique_constraint([:working_group_id, :user_id])
  end
end
