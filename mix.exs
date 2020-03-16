defmodule Cloudevents.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :cloudevents,
      description: "Elixir SDK for CloudEvents",
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      source_url: "https://github.com/kevinbader/cloudevents-ex"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Docs:
      {:ex_doc, ">= 0.19.0", only: :dev},
      # Linting:
      {:credo, ">= 1.1.3", only: [:dev, :test]},
      # Static type checks:
      {:dialyxir, ">= 0.5.0", only: :dev},
      # Run all static code checks via `mix check`:
      {:ex_check, ">= 0.11.0", only: :dev},
      # A library for defining structs with a type without writing boilerplate code:
      {:typed_struct, "~> 0.1.4"},
      # JSON parser that's supposedly faster than poison:
      {:jason, "~> 1.1.2"}
    ]
  end

  defp package do
    [
      name: "cloudevents",
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/kevinbader/cloudevents-ex"}
    ]
  end

  defp docs do
    [
      main: "Cloudevents"
    ]
  end
end
