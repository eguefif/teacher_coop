defmodule TeacherCoop.Dashboard.WordCount do
  @moduledoc """
  Wordcount is a table for statistics. It gathers search terms and group them
  by day.
  count => How many times a lexem occured in search_terms.
  zero_result => How many times this term appears in a search with zero results
  """
  use Ecto.Schema
  import Ecto.Changeset

  schema "word_counts" do
    field :word, :string
    field :frequency, :integer
    field :zero_result_count, :integer
    field :date, :date
  end

  @doc false
  def changeset(word_count, attrs) do
    permitted = [:word, :frequency, :zero_result_count, :date]
    required = permitted

    word_count
    |> cast(attrs, permitted)
    |> validate_required(required)
  end
end
