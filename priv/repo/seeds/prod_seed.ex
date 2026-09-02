defmodule TeacherCoop.Repo.Seeds.ProdSeed do
  @moduledoc """
  Seeds run in the `:prod` environment.
  """

  alias TeacherCoop.Repo.Seeds.IndexSeed

  def seed do
    IndexSeed.seed()
  end
end
