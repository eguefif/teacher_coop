defmodule TeacherCoop.Library.File do
  use Ecto.Schema
  import Ecto.Changeset

  schema "files" do
    field :filename, :string
    field :format, :string
    field :filepath, :string
    field :user_id, :id
    belongs_to(:document, TeacherCoop.Library.Document)

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(file, attrs, document_id) do
    file
    |> cast(attrs, [:filename, :format, :filepath])
    |> validate_required([:filename, :format, :filepath])
    |> put_change(:document_id, document_id)
  end
end
