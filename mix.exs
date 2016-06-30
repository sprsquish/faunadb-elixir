defmodule FaunaDB.Mixfile do
  use Mix.Project

  @description """
    Elixir driver for FaunaDB
  """

  def project do
    [ app: :faunadb,
      version: "0.0.1",
      elixir: "~> 1.0",
      name: "FaunaDB",
      description: @description,
      package: package,
      deps: deps,
      source_url: "https://github.com/faunadb/faunadb-elixir",
      test_coverage: [tool: ExCoveralls]
    ]
  end

  def application do
    [applications: [:httpoison]]
  end

  defp deps do
    [
      {:httpoison, "~> 0.9.0"},
      {:exjsx, "~> 3.2.0"},
      {:calendar, "~> 0.16.0"},
      {:excoveralls, "~> 0.5.5", only: :test}
    ]
  end

  defp package do
    [ maintainers: ["FaunaDB"],
      licenses: ["MPL-2.0"],
      links: %{"Github" => "https://github.com/faunadb/faunadb-elixir"}
    ]
  end
end
