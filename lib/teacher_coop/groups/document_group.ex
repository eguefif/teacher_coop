defmodule TeacherCoop.Groups.DocumentWorkingGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "documents_working_groups" do
    belongs_to :document, TeacherCoop.Workspace.Document
    belongs_to :working_group, TeacherCoop.Groups.WorkingGroup

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(documents_groups, attrs) do
    documents_groups
    |> cast(attrs, [:document_id, :working_group_id])
    |> validate_required([:document_id, :working_group_id])
    |> unique_constraint([:document_id, :working_group_id])
  end
end
