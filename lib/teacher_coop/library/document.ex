defmodule TeacherCoop.Library.Document do
  use Gettext, backend: TeacherCoop.Gettext
  use Ecto.Schema
  import Ecto.Changeset

  @institution_types ["Tout le monde", "École maternelle", "École élémentaire"]

  schema "documents" do
    field :title, :string
    field :description, :string
    field :user_id, :id
    field :institution_type, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(document, attrs, user_scope) do
    permitted = [:title, :description, :institution_type]
    required = permitted

    document
    |> cast(attrs, permitted)
    |> validate_required(required)
    |> validate_institution_types
    |> put_change(:user_id, user_scope.user.id)
  end

  def validate_institution_types(changeset) do
    field = get_field(changeset, :institution_type)

    case field do
      nil ->
        add_error(
          changeset,
          :institution_type,
          "missing field in changeset `{institution_type}`",
          field: :institution_type,
          validations: :institution_type
        )

      value when value in @institution_types ->
        changeset

      value ->
        add_error(
          changeset,
          :institution_type,
          "Wrong type of institution:`{institution_type}`",
          field: value,
          validations: :institution_type
        )
    end
  end

  def institution_types_options() do
    @institution_types
  end
end
