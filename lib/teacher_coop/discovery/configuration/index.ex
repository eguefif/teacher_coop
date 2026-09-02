defmodule TeacherCoop.Discovery.Configuration.Index do
  use Ecto.Schema
  import Ecto.Changeset

  alias TeacherCoop.Discovery.Configuration.EngineConfiguration
  alias TeacherCoop.Accounts.User

  schema "indexes" do
    field :name, :string
    field :state, :string
    field :task_uid, :string
    belongs_to :engine_configuration_id, EngineConfiguration
    belongs_to :user_id, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(index, attrs, user_scope) do
    index
    |> cast(attrs, [:name, :state, :task_uid])
    |> cast_embed(:config, required: true)
    |> validate_required([:name])
    |> put_change(:user_id, user_scope.user.id)
  end
end
