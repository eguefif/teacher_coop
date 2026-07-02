defmodule TeacherCoop.Library.Document do
  use Gettext, backend: TeacherCoop.Gettext
  use Ecto.Schema
  import Ecto.Changeset

  @institution_types ["Tout le monde", "École maternelle", "École élémentaire"]
  @grades [
    "Aucun",
    "PS",
    "MS",
    "GS",
    "CP",
    "CE1",
    "CE2",
    "CM1",
    "CM2",
    "Cycle 1",
    "Cycle 2",
    "Cycle 3"
  ]

  schema "documents" do
    field :title, :string
    field :description, :string
    field :user_id, :id
    field :institution_type, :string
    field :grade, :string
    field :objectives, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(document, attrs, user_scope) do
    permitted = [:title, :description, :institution_type, :grade, :objectives]
    required = permitted |> List.delete(:objectives)

    document
    |> cast(attrs, permitted)
    |> validate_required(required)
    |> validate_enum(@institution_types, :institution_type)
    |> validate_enum(@grades, :grade)
    |> put_change(:user_id, user_scope.user.id)
  end

  def validate_enum(changeset, enum, field) when is_atom(field) do
    value = get_field(changeset, field)

    case value do
      nil ->
        add_error(
          changeset,
          field,
          "Missing field in changeset `{#{field}}`",
          field: field,
          validations: field
        )

      value ->
        if value in enum do
          changeset
        else
          add_error(
            changeset,
            field,
            "Value not in the list:`{field}`",
            field: value,
            validations: field
          )
        end
    end
  end

  def institution_types_options() do
    @institution_types
  end

  def grades_options() do
    @grades
  end
end
