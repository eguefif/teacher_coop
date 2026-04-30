defmodule TeacherCoop.Workspace.Tags do
  @tags %{
    # Grade
    1 => "ps",
    2 => "ms",
    3 => "gs",
    4 => "cp",
    5 => "ce1",
    6 => "ce2",
    7 => "cm1",
    8 => "cm2",
    9 => "segpa",
    10 => "6ème",
    11 => "5ème",
    12 => "4ème",
    13 => "3ème",
    14 => "seconde",
    15 => "première",
    16 => "terminal",
    17 => "général",
    18 => "scientifiques",
    19 => "littéraire",
    20 => "ses",

    # Subject
    29 => "français",
    30 => "mathématiques",
    31 => "histoire",
    32 => "géographie",
    33 => "histoire géographie",
    34 => "svt",
    35 => "physique chimie",
    36 => "physique",
    37 => "chimie",
    38 => "eps",
    39 => "arts visuels",
    40 => "musique",

    # Type of document
    58 => "exercices",
    59 => "séquence",
    60 => "pédagogie",
    61 => "didactique",
    62 => "affiches"
  }

  @doc """
  Returns the list of values.
  """
  def get_all_tags() do
    Map.values(@tags)
  end

  @doc """
  Returns the tags map but values become indexes and indexes become values.

    %{"ps" => 1, "ms" => 2 ...}
  """
  def get_tags_map_by_value() do
    @tags
    |> Map.to_list()
    |> Enum.map(fn {idx, value} -> {value, idx} end)
    |> Map.new()
  end

  @doc """
  Returns a list of tags from a list of indexes.
  """
  def get_tags_from_indexes(indexes) do
    indexes =
      indexes
      |> Enum.map(fn idx -> String.trim(idx) end)
      |> Enum.map(fn idx -> String.to_integer(idx) end)

    case indexes do
      [] ->
        []

      _ ->
        @tags
        |> Map.filter(fn {index, _} -> Enum.any?(indexes, fn idx -> idx == index end) end)
        |> Map.values()
    end
  end

  def get_index_from_value(value) do
    tags_by_value = get_tags_map_by_value()
    Map.get(tags_by_value, value)
  end

  def autocomplete_tags(tag) do
    Map.values(@tags)
    |> Enum.map(fn entry -> {entry, String.jaro_distance(entry, tag)} end)
    |> Enum.filter(fn {_, jaro} -> jaro > 0.5 end)
    |> Enum.sort(fn {_, jaro1}, {_, jaro2} -> jaro1 > jaro2 end)
    |> Enum.map(fn {entry, _} -> entry end)
  end
end
