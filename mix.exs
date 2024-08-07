defmodule PoliceNotifier.MixProject do
  use Mix.Project

  def project do
    [
      app: :police_notifier,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:dotenv, "~> 3.1.0"},
      {:twilio, "~> 0.9.1"},
      {:jason, "~> 1.2"}
    ]
  end
end
