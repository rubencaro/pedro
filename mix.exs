defmodule Pedro.Mixfile do
  use Mix.Project

  def project do
    [app: :pedro,
     version: get_version_number,
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Pedro, []},
     applications: [:phoenix, :phoenix_pubsub, :cowboy, :logger, :gettext, :harakiri],
     included_applications: [:mnesia]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2"},
     {:phoenix_pubsub, "~> 1.0"},
     {:gettext, "~> 0.9"},
     {:cowboy, "~> 1.0"},
     {:bottler, github: "rubencaro/bottler"},
     {:cipher, ">= 1.1.2"},
     {:harakiri, ">= 1.0.2"},
     {:credo, "~> 0.4", only: [:dev, :test]},
     {:poolboy, "~> 1.5"}]
  end

  defp get_version_number do
    commit = :os.cmd('git rev-parse --short HEAD') |> to_string |> String.rstrip(?\n)
    v = "0.1.0+#{commit}"
    if Mix.env == :dev,
      do: v <> "dev",
      else: v
  end
end
