defmodule TeacherCoop.Curriculum.CurriculumItem do
  use Ecto.Schema
  import Ecto.Changeset

  schema "curriculum_items" do
    field :year, :integer
    field :subject, :string
    field :strand, :string
    field :grade, :string
    field :item, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(curriculum_item, attrs) do
    curriculum_item
    |> cast(attrs, [:year, :subject, :strand, :grade, :item])
    |> validate_required([])
  end
end
