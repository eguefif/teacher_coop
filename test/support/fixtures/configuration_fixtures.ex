defmodule TeacherCoop.ConfigurationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `TeacherCoop.Configuration` context.
  """

  alias TeacherCoop.Discovery.Configuration.EngineConfiguration.Config

  @doc """
  Generate a document.
  """
  def index_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        uid: "some description",
        type: "original",
        state: "indexed"
      })

    {:ok, index} = TeacherCoop.Discovery.Configuration.create_index(attrs, scope)
    index
  end

  def configuration_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "A configuration",
        engine: "meilisearch",
        config: Map.from_struct(%Config{})
      })

    {:ok, configuration} = TeacherCoop.Discovery.Configuration.create_configuration(scope, attrs)
    configuration
  end
end
