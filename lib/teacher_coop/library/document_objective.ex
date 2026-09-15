defmodule TeacherCoop.Library.DocumentObjective do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{
          id: integer() | nil,
          document_id: integer() | nil,
          document: TeacherCoop.Library.Document.t() | Ecto.Association.NotLoaded.t() | nil,
          objective_id: integer() | nil,
          objective: TeacherCoop.Curriculum.Objective.t() | Ecto.Association.NotLoaded.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

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
