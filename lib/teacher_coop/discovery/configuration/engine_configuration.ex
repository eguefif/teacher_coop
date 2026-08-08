defmodule TeacherCoop.Discovery.Configuration.EngineConfiguration do
  use Ecto.Schema
  import Ecto.Changeset

  schema "engine_configurations" do
    field :engine, :string
    field :index_name, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)

    embeds_one :config, Config do
      field :filterable_attributes, {:array, :string}

      def changeset(config, attrs) do
        permitted = [:filterable_attributes]

        config
        |> cast(attrs, permitted)
      end
    end
  end

  @doc false
  def changeset(engine_configuration, attrs, user_scope) do
    IO.inspect(attrs)

    engine_configuration
    |> cast(attrs, [:engine, :index_name])
    |> cast_embed(:config, required: true)
    |> validate_required([:engine, :index_name, :config])
    |> put_change(:user_id, user_scope.user.id)
  end
end
