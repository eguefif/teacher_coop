defmodule TeacherCoop.Curriculum.CurriculumIngestion do
  use Ecto.Schema
  import Ecto.Changeset

  @type t() :: %__MODULE__{
          year: integer() | nil,
          subject: String.t() | nil,
          state: String.t() | nil,
          sentry_id: String.t() | nil
        }

  @subjects [
    "français",
    "mathématiques"
  ]

  @states ~w[created ingesting error finished]

  schema "curriculum_ingestions" do
    field :year, :integer
    field :subject, :string
    field :state, :string, default: "created"
    field :sentry_id, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(%__MODULE__{} = ingestion, attrs \\ %{}) do
    ingestion
    |> cast(attrs, [:year, :subject, :state])
    |> validate_required([:year, :subject, :state])
    |> valide_list(:subject, @subjects)
    |> valide_list(:state, @states)
  end

  @spec valide_list(Ecto.Changeset.t(), atom(), list()) :: Ecto.Changeset.t()
  defp valide_list(changeset, field, to_check) do
    field = get_field(changeset, field)

    if field not in to_check do
      add_error(changeset, field, "`{key}` should be one of `{value}`",
        key: field,
        value: Enum.join(to_check, ", ")
      )
    else
      changeset
    end
  end

  def subjects() do
    @subjects
  end
end
