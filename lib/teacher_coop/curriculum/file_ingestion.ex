defmodule TeacherCoop.Curriculum.FileIngestion do
  @doc """
  Parse a curriculum file and return a lists of map attributes.
  `year` Integer: year when the curriculum was published
  `subject` String: french, english ...
  `file` Binary: actual file content from the file

  Returns a `list(map())` with all the attributes required for an objective
  """
  def parse_file(year, subject, file_content) do
    common_data = %{year: year, subject: subject}

    file_content
    |> get_objectives()
    |> Enum.flat_map(& &1)
    |> Enum.map(&Map.merge(common_data, &1))
  end

  defp get_objectives(content) do
    content
    |> get_blocks()
    |> Enum.map(&parse_blocks(&1))
  end

  defp get_blocks(content) do
    String.split(content, "\n\n", trim: true)
  end

  def parse_blocks(block) do
    [first_line | lines] = String.split(block, "\n", trim: true)

    [strand, grade] = get_subject_and_grade(first_line)

    lines
    |> Enum.map(&%{strand: strand, grade: grade, goal: &1})
  end

  defp get_subject_and_grade(line) do
    String.split(line, "-", trim: true)
    |> Enum.map(&String.trim(&1))
  end
end
