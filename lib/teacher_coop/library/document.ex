defmodule TeacherCoop.Library.Document do
  use Gettext, backend: TeacherCoop.Gettext
  use Ecto.Schema
  import Ecto.Changeset

  @institution_types ["école maternelle", "école élémentaire"]

  schema "documents" do
    field :title, :string
    field :description, :string
    field :user_id, :id
    field :institution_type, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(document, attrs, user_scope) do
    document
    |> cast(attrs, [:title, :description, :institution_type])
    |> validate_required([:title, :description])
    |> validate_institution_types
    |> put_change(:user_id, user_scope.user.id)
  end

  def validate_institution_types(changeset) do
    field = get_field(changeset, :institution_type)

    # TODO: add test for validation
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

      _ ->
        add_error(
          changeset,
          :institution_type,
          "missing fiel in changeset `{institution_type}`",
          field: :institution_type,
          validations: :institution_type
        )
    end
  end

  def institution_types_options() do
    @institution_types
  end
end
