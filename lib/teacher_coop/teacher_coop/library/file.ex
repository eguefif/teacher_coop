defmodule TeacherCoop.Library.File do
  use Ecto.Schema
  import Ecto.Changeset

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
