# In this file, we load production configuration and secrets
# from environment variables. You can also hardcode secrets,
# although such is generally not recommended and you have to
# remember to add this file to your .gitignore.
import Config

# database_url =
#   System.get_env("DATABASE_URL") ||
#     raise """
#     environment variable DATABASE_URL is missing.
#     For example: ecto://USER:PASS@HOST/DATABASE
#     """
#
# config :posa, Posa.Repo,
#   # ssl: true,
#   url: database_url,
#   pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")

# ## Using releases (Elixir v1.9+)
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start each relevant endpoint:
#
#     config :posa, PosaWeb.Endpoint, server: true
#
# Then you can assemble a release by calling `mix release`.
# See `mix help release` for more information.
# config :posa, PosaWeb.Endpoint, server: true

# Config
secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
  raise """
  Environment variable SECRET_KEY_BASE is missing.
  You can generate one by calling: mix phx.gen.secret
  """
github_token =
  System.get_env("PHX_GITHUB_TOKEN") ||
  raise """
  Environment variable PHX_GITHUB_TOKEN is missing.
  You need a github token to continue.
  """

organizations = System.get_env("PHX_ORGANIZATIONS", "puzzle") |> String.split(",")
sync_delay_ms = System.get_env("PHX_SYNC_DELAY_MS", "120000") |> String.to_integer

url_host = System.get_env("PHX_HOST", "localhost")
http_port = System.get_env("PHX_HTTP_PORT", "4000") |> String.to_integer

config :posa,
  organizations: organizations,
  github_token: github_token,
  sync_delay_ms: sync_delay_ms

config :posa, PosaWeb.Endpoint,
  server: true,
  url: [host: url_host],
  http: [port: http_port],
  secret_key_base: secret_key_base

# config :posa, PosaWeb.Endpoint,
#   server: true,
#   http: [
#     port: port,
#     transport_options: [socket_opts: [:inet6]]
#   ],
#   secret_key_base: secret_key_base
