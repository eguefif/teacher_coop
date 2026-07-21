defmodule TeacherCoop.Library.DocumentObjective do
  use Ecto.Schema
  import Ecto.Changeset

  schema "document_objectives" do
    belongs_to :document, TeacherCoop.Library.Document, on_replace: :delete
    belongs_to :objective, TeacherCoop.Curriculum.Objective, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(document_objective, attrs) do
    permitted = [:id, :document_id, :objective_id]
    required = permitted |> List.delete(:id)

    document_objective
    |> cast(attrs, permitted)
    |> validate_required(required)
    |> foreign_key_constraint(:document_id)
    |> foreign_key_constraint(:objective_id)
    |> unique_constraint([:document_id, :objective_id])
    |> unique_constraint([:id])
  end
end
