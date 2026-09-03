defmodule TeacherCoop.Discovery.Configuration.EngineConfiguration do
  use Ecto.Schema
  import Ecto.Changeset

  alias TeacherCoop.Discovery.Configuration.Index

  @ranking_rules [
    "words",
    "typo",
    "proximity",
    "attributeRank",
    "sort",
    "wordPosition",
    "exactness"
  ]

  @proximity_precision_values ["byWord", "byAttribute"]

  schema "engine_configurations" do
    field :name, :string
    field :engine, :string
    field :index_names, {:array, :string}
    field :user_id, :id

    has_many :index, Index, on_delete: :nilify_all

    timestamps(type: :utc_datetime)

    embeds_one :config, Config, primary_key: false, on_replace: :update do
      field :facet_search, :boolean, default: true
      field :distinct_attribute, :string, default: nil
      field :proximity_precision, :string, default: "byWord"

      field :filterable_attributes, {:array, :string}, default: []
      field :searchable_attributes, {:array, :string}, default: ["*"]
      field :sortable_attributes, {:array, :string}, default: ["*"]

      field :stop_words, {:array, :string}, default: []
      field :non_separator_tokens, {:array, :string}, default: []
      field :separator_tokens, {:array, :string}, default: []
      field :dictionary, {:array, :string}, default: []

      field :ranking_rules, {:array, :string},
        default: [
          "words",
          "typo",
          "proximity",
          "attributeRank",
          "sort",
          "wordPosition",
          "exactness"
        ]

      embeds_one :embedders, Embedders, primary_key: false, on_replace: :update do
        embeds_one :default, Default, primary_key: false, on_replace: :update do
          field :source, :string, default: "huggingFace"
          field :model, :string, default: "sentence-transformers/all-MiniLM-L6-v2"

          field :document_template, :string,
            default: "A document named {{doc.title}} described as {{doc.description}}"

          def changeset(embedder, attrs) do
            permitted = [:source, :model, :document_template]
            required = permitted

            embedder
            |> cast(attrs, permitted)
            |> validate_required(required)
          end
        end

        def changeset(embedders, attrs) do
          embedders
          |> cast(attrs, [])
          |> cast_embed(:default)
        end
      end

      embeds_one :typo_tolerance, TypoTolerance, primary_key: false, on_replace: :update do
        field :enabled, :boolean, default: true
        field :disable_on_words, {:array, :string}, default: []

        embeds_one :min_word_size_for_typos, MinWordSizeForTypos,
          primary_key: false,
          on_replace: :delete do
          field :one_typo, :integer, default: 5
          field :two_typos, :integer, default: 9

          def changeset(min_size, attrs) do
            min_size
            |> cast(attrs, [:one_typo, :two_typos])
            |> validate_required([:one_typo, :two_typos])
            |> validate_number(:one_typo, greater_than_or_equal_to: 0)
            |> validate_number(:two_typos, greater_than_or_equal_to: 0)
          end
        end

        def changeset(typo_tolerance, attrs) do
          permitted = [:enabled, :disable_on_words]
          required = []

          typo_tolerance
          |> cast(attrs, permitted)
          |> validate_required(required)
          |> cast_embed(:min_word_size_for_typos)
        end
      end

      def changeset(config, attrs) do
        permitted = [
          :distinct_attribute,
          :proximity_precision,
          :filterable_attributes,
          :sortable_attributes,
          :searchable_attributes,
          :stop_words,
          :non_separator_tokens,
          :separator_tokens,
          :dictionary,
          :ranking_rules,
          :facet_search
        ]

        config
        |> cast(attrs, permitted)
        |> cast_embed(:embedders)
        |> cast_embed(:typo_tolerance)
        |> validate_ranking_rules()
        |> validate_proximity_precision()
      end

      defp validate_proximity_precision(changeset) do
        values =
          TeacherCoop.Discovery.Configuration.EngineConfiguration.get_proximity_precision_values()

        field = get_field(changeset, :proximity_precision)

        if field in values do
          changeset
        else
          add_error(
            changeset,
            :proximity_precision,
            "Must be one of %{values}",
            values: Enum.join(values)
          )
        end
      end

      defp validate_ranking_rules(changeset) do
        ranking_rules =
          TeacherCoop.Discovery.Configuration.EngineConfiguration.get_ranking_rules()

        field = get_field(changeset, :ranking_rules)

        rules_valid? = Enum.all?(field, &(&1 in ranking_rules))

        if rules_valid? && length(field) == 7 do
          changeset
        else
          add_error(
            changeset,
            :ranking_rules,
            "Ranking rules should only contains the value: %{values} with 7 values",
            values: Enum.join(ranking_rules, ", ")
          )
        end
      end
    end
  end

  @doc false
  def changeset(engine_configuration, attrs, user_scope) do
    engine_configuration
    |> cast(attrs, [:engine, :index_names, :name])
    |> cast_embed(:config, required: true)
    |> validate_required([:engine, :name])
    |> put_change(:user_id, user_scope.user.id)
  end

  def get_ranking_rules() do
    @ranking_rules
  end

  def get_proximity_precision_values() do
    @proximity_precision_values
  end
end
