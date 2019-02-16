defmodule BrigadeRest.Mixfile do
  use Mix.Project

  def project do
    [
      app: :brigade_rest,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:thrift, :phoenix, :gettext] ++ Mix.compilers,
      thrift: [
        files: Path.wildcard("../thrift-shop/src/**/*.thrift")
      ],
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {BrigadeRest.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.3.2"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},
      {:ranch, "~> 1.6", override: true},
      {:plug_cowboy, "~> 1.0"},
      {:thrift, github: "pinterest/elixir-thrift"},
      {:maptu, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:uuid, "~> 1.1"},
    ]
  end
end
