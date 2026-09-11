defmodule TeacherCoopWeb.YearJSON do
  @doc """
  Renders a list of urls.
  """
  def index(%{year: year}) do
    %{data: year}
  end
end
