# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :posa, ecto_repos: []

# Configures the endpoint
config :posa, PosaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "V5cG1N+E038EoPG3cT2a8ByV8WlnRcb3E+wAsIIjzfcxCwwuYdGbv5qty0CUUWgt",
  render_errors: [view: PosaWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Posa.PubSub,
  live_view: [signing_salt: "e0IYg911"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Use Slim templating
config :phoenix_slime, :use_slim_extension, true

config :phoenix, :template_engines,
  slim: PhoenixSlime.Engine,
  slime: PhoenixSlime.Engine,
  slimleex: PhoenixSlime.LiveViewEngine

# Set Runtime Config
organizations = System.get_env("PHX_ORGANIZATIONS", "puzzle") |> String.split(",")
github_token = System.get_env("PHX_GITHUB_TOKEN")
sync_delay_ms = System.get_env("PHX_SYNC_DELAY_MS", "120000") |> String.to_integer

config :posa,
  organizations: organizations,
  github_token: github_token,
  sync_delay_ms: sync_delay_ms

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
