defmodule TeacherCoop.Workspace.Document do
  use Ecto.Schema
  import Ecto.Changeset

  schema "documents" do
    field :title, :string
    field :description, :string
    field :public, :boolean
    field :tags, {:array, :string}
    field :goals, {:array, :string}
    belongs_to :user, TeacherCoop.Accounts.User
    has_many :files, TeacherCoop.Workspace.File, on_replace: :delete
    has_many :document_working_groups, TeacherCoop.Workspace.Groups.DocumentWorkingGroup

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(document, attrs, user_scope) do
    document
    |> cast(attrs, [:title, :description, :tags, :goals, :public])
    |> validate_required([:title, :description, :tags, :goals])
    |> validate_length(:tags, min: 1, max: 20)
    |> validate_length(:goals, min: 1, max: 20)
    |> validate_length(:title, min: 3, max: 200)
    |> validate_length(:description, min: 5, max: 1200)
    |> validate_length(:tags, min: 0, max: 20)
    |> validate_length(:goals, min: 0, max: 10)
    |> put_change(:user_id, user_scope.user.id)
    |> cast_assoc(:files)
  end

  @doc false
  def changeset_update(document, attrs) do
    document
    |> cast(attrs, [:title, :description, :tags, :goals, :public])
    |> validate_required([:title, :description, :tags, :goals])
    |> validate_length(:tags, min: 1, max: 20)
    |> validate_length(:goals, min: 1, max: 20)
    |> validate_length(:title, min: 3, max: 200)
    |> validate_length(:description, min: 5, max: 1200)
    |> validate_length(:tags, min: 0, max: 20)
    |> validate_length(:goals, min: 0, max: 10)
    |> cast_assoc(:files)
  end

  @doc false
  def to_map(%__MODULE__{} = struct) do
    %{
      id: struct.id,
      title: struct.title,
      description: struct.description,
      public: struct.public,
      tags: struct.tags,
      goals: struct.goals,
      user_id: struct.user.id,
      working_groups: struct.document_working_groups |> Enum.map(&Map.get(&1, :id))
    }
  end
end
