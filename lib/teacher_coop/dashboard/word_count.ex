defmodule TeacherCoop.Dashboard.WordCount do
  use Ecto.Schema
  import Ecto.Changeset

  schema "word_counts" do
    field :word, :string
    field :count, :integer
    field :date, :date
  end

  @doc false
  def changeset(word_count, attrs) do
    permitted = [:word, :count, :date]
    required = permitted

    word_count
    |> cast(attrs, permitted)
    |> validate_required(required)
  end
end
