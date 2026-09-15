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

  @type t() :: %__MODULE__{
          id: integer() | nil,
          uid: String.t(),
          primary_key: String.t() | nil,
          type: String.t() | nil,
          state: String.t() | nil,
          task_uid: String.t() | nil,
          engine_configuration_id: integer() | nil,
          engine_configuration: EngineConfiguration.t() | nil,
          user_id: integer() | nil,
          user: User.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @doc """
  Canonical list of index definitions that should exist in the search engine.

  Used both to seed the `indexes` table and to (re)create the indexes in
  Meilisearch, so the two stay in sync.
  """
  def definitions, do: @definitions

  schema "indexes" do
    field :uid, :string
    field :primary_key, :string, default: "id"
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
    |> cast(attrs, [:uid, :state, :task_uid, :type, :engine_configuration_id])
    |> validate_required([:uid])
    |> put_change(:user_id, user_scope.user.id)
    |> foreign_key_constraint(:engine_configuration_id)
  end

  @doc false
  def changeset_state(index, attrs) do
    index
    |> cast(attrs, [:uid, :state, :task_uid, :type, :engine_configuration_id])
    |> validate_required([:state])
  end
end
