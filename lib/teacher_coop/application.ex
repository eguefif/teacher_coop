defmodule TeacherCoop.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Oban.Telemetry.attach_default_logger()

    children = [
      TeacherCoopWeb.Telemetry,
      TeacherCoop.Repo,
      {DNSCluster, query: Application.get_env(:teacher_coop, :dns_cluster_query) || :ignore},
      {Oban, Application.fetch_env!(:teacher_coop, Oban)},
      {Phoenix.PubSub, name: TeacherCoop.PubSub},
      TeacherCoopWeb.Endpoint,
      {Finch, name: :search_finch},
      {Meilisearch,
       name: :meilisearch,
       endpoint: "http://127.0.0.1:7700",
       key: "masterkey",
       finch: :search_finch}
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
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
