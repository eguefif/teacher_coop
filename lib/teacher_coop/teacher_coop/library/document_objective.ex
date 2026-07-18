defmodule TeacherCoop.TeacherCoop.Library.DocumentObjective do
  use Ecto.Schema
  import Ecto.Changeset

  schema "document_objectives" do
    field :document_id, :id
    field :objective_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(document_objective, attrs) do
    document_objective
    |> cast(attrs, [])
    |> validate_required([])
  end
end
