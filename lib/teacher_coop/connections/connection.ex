defmodule TeacherCoop.Connection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "connections" do
    field :user1_id, :id
    field :user2_id, :id
    field :state, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(connection, attrs) do
    connection
    |> cast(attrs, [:user1_id, :user2_id, :state])
    |> validate_required([:user1_id, :user2_id, :state])
  end
end
