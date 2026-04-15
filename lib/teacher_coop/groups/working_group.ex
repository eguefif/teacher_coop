defmodule TeacherCoop.Groups.WorkingGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "working_groups" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(working_group, attrs) do
    working_group
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
