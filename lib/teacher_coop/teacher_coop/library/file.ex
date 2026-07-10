defmodule TeacherCoop.TeacherCoop.Library.File do
  use Ecto.Schema
  import Ecto.Changeset

  schema "files" do
    field :filename, :string
    field :format, :string
    field :filepath, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(file, attrs, user_scope) do
    file
    |> cast(attrs, [:filename, :format, :filepath])
    |> validate_required([:filename, :format, :filepath])
    |> put_change(:user_id, user_scope.user.id)
  end
end
