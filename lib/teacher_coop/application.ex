defmodule TeacherCoop.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    unless Mix.env() == :prod do
      Dotenv.load()
    end

    children = [
      TeacherCoopWeb.Telemetry,
      TeacherCoop.Repo,
      {DNSCluster, query: Application.get_env(:teacher_coop, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TeacherCoop.PubSub},
      {Finch, name: :search_finch},
      {Meilisearch,
       name: :meili_teachercoop,
       endpoint: Dotenv.get("MEILISEARCH_HOST", "http://127.0.0.1:7700"),
       key: Dotenv.get("MEILI_MASTER_KEY", ""),
       finch: :search_finch},
      TeacherCoopWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TeacherCoop.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TeacherCoopWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
