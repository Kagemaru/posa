defmodule Posa.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    startup_checks()
    children = [

      # Start github stuff
      Posa.Github,
      # Start the Telemetry supervisor
      PosaWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Posa.PubSub},
      # Start the Endpoint (http/https)
      PosaWeb.Endpoint
      # Start a worker by calling: Posa.Worker.start_link(arg)
      # {Posa.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Posa.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PosaWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp startup_checks() do
    IO.puts "Checking ENV vars:"
    check_env :organizations, "Organizations"
    check_env :sync_delay_ms, "Sync Delay (ms)"
    check_env :github_token, "Github Token"
    IO.puts "All ENV vars correclty set"
  end

  defp check_env(key, label) do
    IO.write "Testing #{label} => "

    value = Application.fetch_env(:posa, key) |> check_value

    IO.write value
    IO.puts " => OK"
  end

  defp check_value(nil), do: exit(:env_var_empty)
  defp check_value(value), do: value
end
