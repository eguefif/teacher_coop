defmodule TeacherCoop.Discovery.Configuration.EngineConfiguration do
  use Ecto.Schema
  import Ecto.Changeset

  schema "engine_configurations" do
    field :engine, :string
    field :config, :map
    field :index_name, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(engine_configuration, attrs, user_scope) do
    engine_configuration
    |> cast(attrs, [:engine, :config, :index_name])
    |> validate_required([:engine, :index_name])
    |> put_change(:user_id, user_scope.user.id)
  end
end
