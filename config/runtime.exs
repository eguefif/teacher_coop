import Config

# config/runtime.exs is executed for all environments, including
# during releases. It is executed after compilation and before the
# system starts, so it is typically used to load production configuration
# and secrets from environment variables or elsewhere. Do not define
# any compile-time configuration in here, as it won't be applied.
# The block below contains prod specific runtime configuration.

# ## Using releases
#
# If you use `mix release`, you need to explicitly enable the server
# by passing the PHX_SERVER=true when you start it:
#
#     PHX_SERVER=true bin/teacher_coop start
#
# Alternatively, you can use `mix phx.gen.release` to generate a `bin/server`
# script that automatically sets the env var above.
if System.get_env("PHX_SERVER") do
  config :teacher_coop, TeacherCoopWeb.Endpoint, server: true
end

config :teacher_coop, TeacherCoopWeb.Endpoint,
  http: [port: String.to_integer(System.get_env("PORT", "4000"))]

if config_env() == :prod do
  read_secret = fn name ->
    "/run/secrets/#{name}" |> File.read!() |> String.trim()
  end

  database_url = read_secret.("database_url")

  maybe_ipv6 = if System.get_env("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

  config :teacher_coop, TeacherCoop.Repo,
    # ssl: true,
    url: database_url,
    pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10"),
    # For machines with several cores, consider starting multiple pools of `pool_size`
    # pool_count: 4,
    socket_options: maybe_ipv6

  # The secret key base is used to sign/encrypt cookies and other secrets.
  # A default value is used in config/dev.exs and config/test.exs but you
  # want to use a different value for prod and you most likely don't want
  # to check this value into version control, so we use an environment
  # variable instead.
  secret_key_base = read_secret.("secret_key_base")

  host = System.get_env("PHX_HOST") || "teachercoop.org"

  config :teacher_coop, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :teacher_coop, TeacherCoopWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      # Enable IPv6 and bind on all interfaces.
      # Set it to  {0, 0, 0, 0, 0, 0, 0, 1} for local network only access.
      # See the documentation on https://bandit.hexdocs.pm/Bandit.html#t:options/0
      # for details about using IPv6 vs IPv4 and loopback vs public addresses.
      ip: {0, 0, 0, 0, 0, 0, 0, 0}
    ],
    secret_key_base: secret_key_base

  # ## SSL Support
  #
  # To get SSL working, you will need to add the `https` key
  # to your endpoint configuration:
  #
  #     config :teacher_coop, TeacherCoopWeb.Endpoint,
  #       https: [
  #         ...,
  #         port: 443,
  #         cipher_suite: :strong,
  #         keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
  #         certfile: System.get_env("SOME_APP_SSL_CERT_PATH")
  #       ]
  #
  # The `cipher_suite` is set to `:strong` to support only the
  # latest and more secure SSL ciphers. This means old browsers
  # and clients may not be supported. You can set it to
  # `:compatible` for wider support.
  #
  # `:keyfile` and `:certfile` expect an absolute path to the key
  # and cert in disk or a relative path inside priv, for example
  # "priv/ssl/server.key". For all supported SSL configuration
  # options, see https://plug.hexdocs.pm/Plug.SSL.html#configure/1
  #
  # We also recommend setting `force_ssl` in your config/prod.exs,
  # ensuring no data is ever sent via http, always redirecting to https:
  #
  #     config :teacher_coop, TeacherCoopWeb.Endpoint,
  #       force_ssl: [hsts: true]
  #
  # Check `Plug.SSL` for all available options in `force_ssl`.

  # ## Configuring the mailer
  #
  # In production you need to configure the mailer to use a different adapter.
  # Here is an example configuration for Mailgun:

  config :teacher_coop, TeacherCoop.Mailer,
    adapter: Swoosh.Adapters.Mailgun,
    base_url: System.get_env("MAILGUN_BASE_URL"),
    api_key: read_secret.("mailgun_sending_key"),
    domain: System.get_env("MAILGUN_DOMAIN")

  # See https://swoosh.hexdocs.pm/Swoosh.html#module-installation for details.

  # Configure the S3 Filestore
  config :teacher_coop, TeacherCoop.FileStore,
    endpoint: "https://teachercoop.s3.fr-par.scw.cloud",
    access_key_id: read_secret.("access_key_id"),
    secret_access_key: read_secret.("secret_access_key"),
    bucket: "teachercoop",
    region: "fr-par"

  config :teacher_coop, TeacherCoop.SearchRepo,
    hostname: "http://meilisearch:7700",
    masterkey: read_secret.("meili_master_key")
end
