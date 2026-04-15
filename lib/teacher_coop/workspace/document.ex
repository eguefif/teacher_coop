defmodule TeacherCoop.Workspace.Document do
  use Ecto.Schema
  import Ecto.Changeset

  schema "documents" do
    field :title, :string
    field :description, :string
    field :tags, {:array, :string}
    field :goals, {:array, :string}
    belongs_to :user, TeacherCoop.Accounts.User
    has_many :files, TeacherCoop.Workspace.File

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(document, attrs, user_scope) do
    document
    |> cast(attrs, [:title, :description, :tags, :goals])
    |> validate_required([:title, :description])
    |> validate_length(:title, min: 3, max: 200)
    |> validate_length(:description, min: 5, max: 1200)
    |> validate_length(:tags, min: 0, max: 20)
    |> validate_length(:goals, min: 0, max: 10)
    |> put_change(:user_id, user_scope.user.id)
    |> cast_assoc(:files, with: &TeacherCoop.Workspace.File.changeset/3)
  end
end
