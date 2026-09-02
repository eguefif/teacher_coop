defmodule TeacherCoop.Discovery.Configuration.EngineConfiguration do
  use Ecto.Schema
  import Ecto.Changeset

  alias TeacherCoop.Discovery.Configuration.Index

  schema "engine_configurations" do
    field :name, :string
    field :engine, :string
    field :index_names, {:array, :string}
    field :user_id, :id

    has_many :index, Index, on_delete: :nilify_all

    timestamps(type: :utc_datetime)

    embeds_one :config, Config, primary_key: false, on_replace: :update do
      field :filterable_attributes, {:array, :string}

      embeds_many :embedders, Embedder, primary_key: false, on_replace: :delete do
        field :name, :string
        field :source, :string
        field :model, :string
        field :document_template, :string

        def changeset(embedder, attrs) do
          permitted = [:name, :source, :model, :document_template]
          required = permitted

          embedder
          |> cast(attrs, permitted)
          |> validate_required(required)
        end
      end

      def changeset(config, attrs) do
        permitted = [:filterable_attributes]

        config
        |> cast(attrs, permitted)
        |> cast_embed(:embedders, drop_param: :embedders_drop, sort_params: :embedders_sort)
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
end
