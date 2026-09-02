# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TeacherCoop.Repo.insert!(%TeacherCoop.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias TeacherCoop.Repo.Seeds.{DevSeed, ProdSeed}

if Mix.env() == :dev do
  DevSeed.seed()
end

if Mix.env() == :prod do
  ProdSeed.seed()
end
