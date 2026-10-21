defmodule Mailcast.MixProject do
  use Mix.Project

  @github_url "https://github.com/mailcastio/mailcast-elixir"
  @version "0.0.11"

  def project do
    [
      app: :mailcast,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: @github_url,
      docs: fn ->
        [
          source_ref: "#{@version}",
          canonical: "https://mailcast.hexdocs.pm",
          main: "Mailcast",
          source_url: @github_url,
          extras: ["README.md"]
        ]
      end,
      description: description(),
      package: package()
    ]
  end

  defp description do
    "Mailcast Elixir SDK"
  end

  defp package do
    [
      maintainers: ["Andrew Timberlake"],
      licenses: ["MIT"],
      links: %{"Github" => @github_url}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:bandit, "~> 1.0", only: :test},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:plug, "~> 1.15"},
      {:quokka, "~> 2.0", only: [:dev, :test], runtime: false},
      {:req, "~> 0.0", optional: true},
      {:sham, "~> 1.0", only: :test},
      {:swoosh, "~> 1.3", optional: true}
    ]
  end
end
