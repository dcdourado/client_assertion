defmodule ClientAssertion.MixProject do
  use Mix.Project

  def project do
    [
      app: :client_assertion,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:crypto, :logger]
    ]
  end

  defp deps do
    [
      {:joken, "~> 2.5.0"},
      {:jason, "~> 1.3.0"},
      {:uuid, "~> 1.1.8"}
    ]
  end
end
