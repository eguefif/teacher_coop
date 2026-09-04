defmodule TeacherCoop.Discovery.Configuration.Index do
  use Ecto.Schema
  import Ecto.Changeset

  alias TeacherCoop.Discovery.Configuration.EngineConfiguration
  alias TeacherCoop.Accounts.User

  @definitions [
    %{uid: "documents", primary_key: "id", type: "original", state: "indexed"},
    %{uid: "documents_test", primary_key: "id", type: "original", state: "indexed"},
    %{uid: "objectives", primary_key: "id", type: "original", state: "indexed"},
    %{uid: "objectives_test", primary_key: "id", type: "original", state: "indexed"}
  ]

  @doc """
  Canonical list of index definitions that should exist in the search engine.

  Used both to seed the `indexes` table and to (re)create the indexes in
  Meilisearch, so the two stay in sync.
  """
  def definitions, do: @definitions

  schema "indexes" do
    field :name, :string
    field :type, :string, default: "copy"
    field :state, :string, default: "indexed"
    field :task_uid, :string
    belongs_to :engine_configuration, EngineConfiguration
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(index, attrs, user_scope) do
    index
    |> cast(attrs, [:name, :state, :task_uid, :type, :engine_configuration_id])
    |> validate_required([:name])
    |> put_change(:user_id, user_scope.user.id)
    |> foreign_key_constraint(:engine_configuration_id)
  end

  @doc false
  def changeset_state(index, attrs) do
    index
    |> cast(attrs, [:name, :state, :task_uid, :type, :engine_configuration_id])
    |> validate_required([:state])
  end
end
