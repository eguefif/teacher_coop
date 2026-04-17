defmodule TeacherCoop.Colleague do
  use Ecto.Schema
  import Ecto.Changeset

  schema "colleagues" do
    field :user1_id, :id
    field :user2_id, :id
    field :state, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(colleague, attrs) do
    colleague
    |> cast(attrs, [:user1_id, :user2_id, :state])
    |> validate_required([:user1_id, :user2_id, :state])
  end
end
