defmodule TeacherCoop.MixProject do
  use Mix.Project

  def project do
    [
      app: :teacher_coop,
      version: "0.1.0",
      elixir: "~> 1.20",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: [:phoenix_live_view] ++ Mix.compilers(),
      # Without line numbers, references don't change on unrelated edits,
      # so the Gettext CI check only fails when messages actually change.
      gettext: [write_reference_line_numbers: false],
      listeners: [Phoenix.CodeReloader],
      name: "Teacher Coop",
      source_url: "https://github.com/eguefif/teacher_coop",
      docs: [
        extras: ["README.md"]
      ],
      dialyzer: [
        plt_local_path: "priv/plts",
        plt_core_path: "priv/plts"
      ],
      test_coverage: [
        ignore_modules: [
          # These are used for seeding
          TeacherCoop.SearchRepo.SearchObjectives,
          TeacherCoop.SearchRepo.Init,
          TeacherCoop.Application,
          # Complex UI liveview that might change, better to test manually
          TeacherCoop.DocumentLive.Components,
          TeacherCoopWeb.FileController,
          TeacherCoopWeb.DocumentLive.Form,
          TeacherCoopWeb.DocumentController,
          # Test fixtures
          TeacherCoop.AccountsFixtures,
          TeacherCoop.DashboardFixtures,
          TeacherCoop.DiscoveryFixtures,
          # Skip the following Phoenix Modules
          Mix.Tasks.Gettext.CheckTranslations,
          TeacherCoopWeb.CoreComponents,
          TeacherCoopWeb.ErrorHTML,
          TeacherCoopWeb.Telemetry,
          TeacherCoopWeb.Layouts,
          TeacherCoopWeb.PageHTML,
          TeacherCoopWeb.PageController,
          TeacherCoopWeb.Router,
          TeacherCoopWeb,
          TeacherCoop.Release
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {TeacherCoop.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  def cli do
    [
      preferred_envs: [precommit: :test]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib", "priv/repo/seeds"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:ex_doc, "~> 0.40.4", only: :dev, runtime: false},
      {:bcrypt_elixir, "~> 3.3.2"},
      {:phoenix, "~> 1.8.14"},
      {:phoenix_ecto, "~> 4.7"},
      {:ecto_sql, "~> 3.14"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.2.0"},
      {:lazy_html, ">= 0.1.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.10", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.5.1", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.2.0",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.28"},
      {:hackney, "~> 4.8.1"},
      {:multipart, "~> 0.6.1"},
      {:plug, "~> 1.20.3"},
      {:req, "~> 0.7.4"},
      {:telemetry_metrics, "~> 1.2"},
      {:telemetry_poller, "~> 1.3"},
      {:gettext, "~> 1.0.2"},
      {:jason, "~> 1.4.5"},
      {:dns_cluster, "~> 0.3.0"},
      {:bandit, "~> 1.5"},
      {:meilisearch_ex, "~> 1.2.1"},
      {:dotenv, "~> 3.1.0"},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      {:oban, "~> 2.24.1"},
      {:oban_web, "~> 2.11"},
      {:igniter, "~> 0.5", only: [:dev]},
      {:contex, "~> 0.5.0"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.3.2", only: [:test]}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: [
        "deps.get",
        "ecto.setup",
        "assets.setup",
        "assets.build",
        "seed",
        "meilisearch.setup"
      ],
      reset: ["meilisearch.setup", "ecto.reset", "populate_curriculum", "seed"],
      seed: ["run priv/repo/seeds.exs"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["meilisearch.reset_test", "ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["compile", "tailwind teacher_coop", "esbuild teacher_coop"],
      "assets.deploy": [
        "tailwind teacher_coop --minify",
        "esbuild teacher_coop --minify",
        "phx.digest"
      ],
      precommit: ["compile --warnings-as-errors", "deps.unlock --unused", "format", "test"],
      "meilisearch.setup": ["run --no-start priv/meilisearch/meilisearch_init.exs"],
      "meilisearch.reset_test": ["run --no-start priv/meilisearch/meilisearch_reset_test.exs"],
      populate_curriculum: ["run priv/curriculum/curriculum_populating.exs"]
    ]
  end
end
