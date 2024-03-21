defmodule Posa.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start github stuff
      Posa.Github,
      PosaWeb.Telemetry,
      # Posa.Repo,
      {DNSCluster, query: Application.get_env(:posa, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Posa.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Posa.Finch},
      # Start a worker by calling: Posa.Worker.start_link(arg)
      # {Posa.Worker, arg},
      # Start to serve requests, typically the last entry
      PosaWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Posa.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PosaWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
