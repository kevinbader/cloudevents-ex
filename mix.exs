defmodule Cloudevents.MixProject do
  @moduledoc false
  use Mix.Project

  def project do
    [
      app: :cloudevents,
      description: description(),
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      docs: docs(),
      source_url: "https://github.com/kevinbader/cloudevents-ex",
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      # applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Docs:
      {:ex_doc, ">= 0.22.1", only: :dev},
      # Linting:
      {:credo, ">= 1.4.0", only: [:dev, :test]},
      # Static type checks:
      {:dialyxir, ">= 1.0.0", only: :dev},
      # Run all static code checks via `mix check`:
      {:ex_check, ">= 0.11.0", only: :dev},
      # A library for defining structs with a type without writing boilerplate code:
      {:typed_struct, "~> 0.2.0"},
      # JSON parser:
      {:jason, "~> 1.2"},
      # Avro encoding/decoding:
      {:avrora, "~> 0.11"}
    ]
  end

  defp description do
    """
    Elixir SDK for CloudEvents, with bindings for JSON, AVRO, HTTP, Kafka.
    """
  end

  defp package do
    [
      name: "cloudevents",
      maintainers: ["Kevin Bader"],
      licenses: ["Apache-2.0"],
      links: %{
        "GitHub" => "https://github.com/kevinbader/cloudevents-ex"
      }
    ]
  end

  defp docs do
    [
      main: "Cloudevents",
      before_closing_body_tag: fn _format ->
        """
        <script type="text/javascript">
          ["badges", "status"].forEach(function(id) {
            var element = document.getElementById(id);
            element.parentNode.removeChild(element);
          });
        </script>
        """
      end
    ]
  end

  defp aliases do
    [
      release: [
        "check",
        fn _ ->
          version = Keyword.get(project(), :version)
          Mix.shell().cmd("git tag v#{version}")
          Mix.shell().cmd("git push --tags")
        end,
        "hex.publish"
      ]
    ]
  end
end
