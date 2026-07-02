defmodule TeacherCoop.Curriculum.Objective do
  use Ecto.Schema
  import Ecto.Changeset

  schema "objectives" do
    field :year, :integer
    field :subject, :string
    field :grade, :string
    field :goal, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(objective, attrs, user_scope) do
    objective
    |> cast(attrs, [:year, :subject, :grade, :goal])
    |> validate_required([:year, :subject, :grade, :goal])
    |> put_change(:user_id, user_scope.user.id)
  end
end
