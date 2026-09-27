defmodule TeacherCoop.Curriculum.Ingestion do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{
          grade: String.t() | nil,
          subject: String.t() | nil,
          file_content: String.t() | nil
        }

  @subjects [
    "français",
    "mathématiques"
  ]

  @grades [
    "ps",
    "ms",
    "gs",
    "cp",
    "ce1",
    "ce2",
    "cm1",
    "cm2",
    "6",
    "5",
    "4",
    "3",
    "2",
    "terminal"
  ]

  schema "Ingestion" do
    field :grade, :string
    field :subject, :string
    field :file_content, :string
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = ingestion, attrs \\ %{}) do
    ingestion
    |> cast(attrs, [:grade, :subject, :file_content])
    |> validate_required([:grade, :subject, :file_content])
    |> validate_field(:grade, @grades)
    |> validate_field(:subject, @subjects)
  end

  @spec validate_field(Ecto.Changeset.t(), atom(), list()) :: Ecto.Changeset.t()
  defp validate_field(changeset, field, to_check) do
    field = get_field(changeset, field)

    if field not in to_check do
      add_error(changeset, :grade, "`{key}` should be one of `{value}`",
        key: field,
        value: Enum.join(to_check, ", ")
      )
    else
      changeset
    end
  end

  def grades() do
    @grades
  end

  def subjects() do
    @subjects
  end
end
