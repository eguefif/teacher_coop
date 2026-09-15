defmodule TeacherCoop.Discovery.SearchResult do
  defstruct [:facets, :hits]

  @type t() :: %__MODULE__{
          facets: map(),
          hits: [map()]
        }
end
