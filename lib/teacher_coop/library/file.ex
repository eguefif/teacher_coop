defmodule TeacherCoop.Library.File do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: integer() | nil,
          filename: String.t(),
          filepath: String.t(),
          format: String.t(),
          document_id: integer() | nil,
          document: TeacherCoop.Library.Document.t() | Ecto.Association.NotLoaded.t() | nil
        }

  schema "files" do
    field :filename, :string
    field :filepath, :string
    field :format, :string
    belongs_to(:document, TeacherCoop.Library.Document)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(file, attrs) do
    permitted = [:filename, :filepath, :format]
    required = permitted

    file
    |> cast(attrs, permitted)
    |> validate_required(required)
  end
end
