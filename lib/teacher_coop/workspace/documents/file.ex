defmodule TeacherCoop.Workspace.File do
  use Ecto.Schema
  import Ecto.Changeset

  schema "files" do
    field :filename, :string
    field :path, :string
    field :format, :string
    belongs_to :document, TeacherCoop.Workspace.Document, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(file, attrs) do
    file
    |> cast(attrs, [:filename, :path, :format])
    |> validate_required([:filename, :path])
  end
end
