defmodule TeacherCoop.ConfigurationTest do
  use TeacherCoop.DataCase
  alias TeacherCoop.Discovery.Configuration
  alias TeacherCoop.Discovery.Configuration.Index
  alias TeacherCoop.Discovery.Configuration.Workers.UpdateConfig

  describe "configuration" do
    import TeacherCoop.AccountsFixtures, only: [user_scope_fixture: 1]
    import TeacherCoop.ConfigurationFixtures

    test "get_index/2 return one index" do
      scope = user_scope_fixture(:admin)
      index = index_fixture(scope) |> Map.update(:engine_configuration, nil, fn _ -> nil end)

      assert Configuration.get_index!(index.id, scope) == index
    end

    test "get_index/2 return one index using :bypass_auth" do
      scope = user_scope_fixture(:admin)

      index =
        index_fixture(scope) |> Map.update(:engine_configuration, nil, fn _ -> nil end)

      assert Configuration.get_index!(index.id, :bypass_auth) == index
    end

    test "get_index_by_name/2 return one index" do
      scope = user_scope_fixture(:admin)

      index =
        index_fixture(scope) |> Map.update(:engine_configuration, nil, fn _ -> nil end)

      assert Configuration.get_index_by_name!(index.name, :bypass_auth) == index
    end

    test "set_index_to_error_indexing/1" do
      scope = user_scope_fixture(:admin)

      index =
        index_fixture(scope)

      Configuration.set_index_to_error_indexing(index)
      index = Configuration.get_index!(index.id, scope)
      assert index.state == "error_indexing"
    end

    test "set_index_to_indexing/1" do
      scope = user_scope_fixture(:admin)

      index =
        index_fixture(scope)

      Configuration.set_index_to_indexing(index)
      index = Configuration.get_index!(index.id, scope)
      assert index.state == "indexing"
    end

    test "set_index_to_indexed/1" do
      scope = user_scope_fixture(:admin)

      index =
        index_fixture(scope)

      Configuration.set_index_to_indexed(index)
      index = Configuration.get_index!(index.id, scope)
      assert index.state == "indexed"
    end

    test "change_index/1 returns a document changeset" do
      scope = user_scope_fixture(:admin)
      index = index_fixture(scope)
      assert %Ecto.Changeset{} = Configuration.change_index(scope, index)
    end

    test "change_index/1 returns error with missing name" do
      scope = user_scope_fixture(:admin)

      attrs = %{
        state: "indexing"
      }

      changeset = Index.changeset(%Index{}, attrs, scope)
      assert changeset.valid? == false
      assert List.keymember?(changeset.errors, :name, 0)
    end

    test "list_index/1" do
      scope = user_scope_fixture(:admin)
      index = index_fixture(scope) |> Map.update(:engine_configuration, nil, fn _ -> nil end)

      assert Configuration.list_index(scope) == [index]
    end

    test "delete_index/2" do
      scope = user_scope_fixture(:admin)
      index = index_fixture(scope) |> Map.update(:engine_configuration, nil, fn _ -> nil end)

      Configuration.delete_index(index, scope)
      assert Configuration.list_index(scope) == []
    end

    test "create_index/2 with engine_configuration_id to schedule oban" do
      scope = user_scope_fixture(:admin)
      config = configuration_fixture(scope)

      attrs = %{
        name: "An index",
        engine_configuration_id: config.id
      }

      {:ok, index} = Configuration.create_index(attrs, scope)

      assert_enqueued worker: UpdateConfig,
                      args: %{
                        "indexname" => index.name,
                        "config_id" => config.id
                      }
    end

    test "update_index/2 update name" do
      scope = user_scope_fixture(:admin)
      config = configuration_fixture(scope)

      attrs = %{
        name: "An index",
        engine_configuration_id: config.id
      }

      {:ok, index} = Configuration.create_index(attrs, scope)

      {:ok, index} = Configuration.update_index(index, %{name: "New name"}, scope)
      assert index.name == "New name"
    end

    test "update_index/2 with engine_configuration_id to schedule oban" do
      scope = user_scope_fixture(:admin)
      config = configuration_fixture(scope)

      attrs = %{
        name: "An index",
        engine_configuration_id: config.id
      }

      {:ok, index} = Configuration.create_index(attrs, scope)

      {:ok, index} = Configuration.update_index(index, %{name: "New name"}, scope)

      assert_enqueued worker: UpdateConfig,
                      args: %{
                        "indexname" => index.name,
                        "config_id" => config.id
                      }
    end
  end

  describe "engine_configuration" do
    import TeacherCoop.AccountsFixtures, only: [user_scope_fixture: 1]
    import TeacherCoop.ConfigurationFixtures

    test "get_configuration!/2 returns one configuration" do
      scope = user_scope_fixture(:admin)
      config = configuration_fixture(scope)

      assert Configuration.get_configuration!(scope, config.id) == config
    end

    test "get_configuration!/2 returns one configuration using :bypass_auth" do
      scope = user_scope_fixture(:admin)
      config = configuration_fixture(scope)

      assert Configuration.get_configuration!(:bypass_auth, config.id) == config
    end

    test "list_configurations/1 returns all configurations" do
      scope = user_scope_fixture(:admin)
      config = configuration_fixture(scope)

      assert Configuration.list_configurations(scope) == [config]
    end

    test "delete_configuration/2 deletes the configuration" do
      scope = user_scope_fixture(:admin)
      config = configuration_fixture(scope)

      assert {:ok, _} = Configuration.delete_configuration(scope, config)
      assert Configuration.list_configurations(scope) == []
    end

    test "create_configuration/2 inserts a configuration" do
      scope = user_scope_fixture(:admin)

      attrs = %{
        name: "A configuration",
        engine: "meilisearch",
        config: Map.from_struct(%TeacherCoop.Discovery.Configuration.EngineConfiguration.Config{})
      }

      assert {:ok, config} = Configuration.create_configuration(scope, attrs)
      assert config.name == "A configuration"
      assert config.engine == "meilisearch"
      assert config.user_id == scope.user.id
    end

    test "create_configuration/2 with index_names schedules oban" do
      scope = user_scope_fixture(:admin)

      attrs = %{
        name: "A configuration",
        engine: "meilisearch",
        index_names: ["an_index"],
        config: Map.from_struct(%TeacherCoop.Discovery.Configuration.EngineConfiguration.Config{})
      }

      {:ok, config} = Configuration.create_configuration(scope, attrs)

      assert_enqueued worker: UpdateConfig,
                      args: %{
                        "indexname" => "an_index",
                        "config_id" => config.id
                      }
    end

    test "update_configuration/3 updates the name" do
      scope = user_scope_fixture(:admin)
      config = configuration_fixture(scope)

      assert {:ok, config} =
               Configuration.update_configuration(scope, config, %{name: "New name"})

      assert config.name == "New name"
    end

    test "update_configuration/3 with index_names schedules oban" do
      scope = user_scope_fixture(:admin)
      config = configuration_fixture(scope)

      {:ok, config} =
        Configuration.update_configuration(scope, config, %{index_names: ["an_index"]})

      assert_enqueued worker: UpdateConfig,
                      args: %{
                        "indexname" => "an_index",
                        "config_id" => config.id
                      }
    end

    test "change_configuration/3 returns a configuration changeset" do
      scope = user_scope_fixture(:admin)
      config = configuration_fixture(scope)

      assert %Ecto.Changeset{} = Configuration.change_configuration(scope, config)
    end

    test "EngineConfiguration.changeset/3 casts the full range of config values" do
      scope = user_scope_fixture(:admin)

      config_attrs = %{
        facet_search: false,
        distinct_attribute: "isbn",
        proximity_precision: "byAttribute",
        filterable_attributes: ["author", "year"],
        searchable_attributes: ["title", "description"],
        sortable_attributes: ["year"],
        stop_words: ["the", "a"],
        non_separator_tokens: ["@", "#"],
        separator_tokens: ["|"],
        dictionary: ["J. R. R.", "Dr."],
        ranking_rules: [
          "typo",
          "words",
          "proximity",
          "attributeRank",
          "sort",
          "wordPosition",
          "exactness"
        ],
        embedders: %{
          default: %{
            source: "openAi",
            model: "text-embedding-3-small",
            document_template: "{{doc.title}}"
          }
        },
        typo_tolerance: %{
          enabled: false,
          disable_on_words: ["ecto"],
          min_word_size_for_typos: %{one_typo: 4, two_typos: 8}
        }
      }

      attrs = %{
        name: "Full configuration",
        engine: "meilisearch",
        index_names: ["documents", "documents_test"],
        config: config_attrs
      }

      changeset =
        TeacherCoop.Discovery.Configuration.EngineConfiguration.changeset(
          %TeacherCoop.Discovery.Configuration.EngineConfiguration{},
          attrs,
          scope
        )

      assert changeset.valid?

      applied = Ecto.Changeset.apply_changes(changeset)

      assert applied.name == "Full configuration"
      assert applied.engine == "meilisearch"
      assert applied.index_names == ["documents", "documents_test"]
      assert applied.user_id == scope.user.id

      config = applied.config
      assert config.facet_search == false
      assert config.distinct_attribute == "isbn"
      assert config.proximity_precision == "byAttribute"
      assert config.filterable_attributes == ["author", "year"]
      assert config.searchable_attributes == ["title", "description"]
      assert config.sortable_attributes == ["year"]
      assert config.stop_words == ["the", "a"]
      assert config.non_separator_tokens == ["@", "#"]
      assert config.separator_tokens == ["|"]
      assert config.dictionary == ["J. R. R.", "Dr."]

      assert config.ranking_rules == [
               "typo",
               "words",
               "proximity",
               "attributeRank",
               "sort",
               "wordPosition",
               "exactness"
             ]

      assert config.embedders.default.source == "openAi"
      assert config.embedders.default.model == "text-embedding-3-small"
      assert config.embedders.default.document_template == "{{doc.title}}"

      assert config.typo_tolerance.enabled == false
      assert config.typo_tolerance.disable_on_words == ["ecto"]
      assert config.typo_tolerance.min_word_size_for_typos.one_typo == 4
      assert config.typo_tolerance.min_word_size_for_typos.two_typos == 8
    end
  end
end
