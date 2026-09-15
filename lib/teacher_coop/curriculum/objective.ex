defmodule TeacherCoop.Curriculum.Objective do
  use Ecto.Schema
  import Ecto.Changeset

  alias TeacherCoop.Library

  @type t() :: %__MODULE__{
          id: integer() | nil,
          year: integer(),
          subject: String.t(),
          grade: String.t(),
          strand: String.t() | nil,
          goal: String.t(),
          document_objectives: [Library.DocumentObjective.t()] | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "objectives" do
    field :year, :integer
    field :subject, :string
    field :grade, :string
    field :strand, :string
    field :goal, :string
    has_many :document_objectives, Library.DocumentObjective, on_replace: :delete

    many_to_many :documents, Library.Document,
      join_through: Library.DocumentObjective,
      on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(objective, attrs) do
    objective
    |> cast(attrs, [:id, :year, :subject, :grade, :goal])
    |> validate_required([:year, :subject, :grade, :goal])
  end
end
