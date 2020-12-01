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

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
  raise """
  environment variable SECRET_KEY_BASE is missing.
  You can generate one by calling: mix phx.gen.secret
  """

url_host = System.get_env("PHX_HOST", "localhost")
http_port = System.get_env("PHX_HTTP_PORT", "4000") |> String.to_integer
https_port = System.get_env("PHX_HTTPS_PORT", "4001") |> String.to_integer
https_keyfile = System.get_env("PHX_SSL_KEYFILE")
https_certfile = System.get_env("PHX_SSL_CERTFILE")
https_cacertfile = System.get_env("PHX_SSL_CA_CERTFILE")

config :posa, PosaWeb.Endpoint,
  server: true,
  url: [host: url_host],
  http: [port: http_port],
  https: [
    port: https_port,
    keyfile: https_keyfile,
    certfile: https_certfile,
    cacertfile: https_cacertfile
  ]

# config :posa, PosaWeb.Endpoint,
#   server: true,
#   http: [
#     port: port,
#     transport_options: [socket_opts: [:inet6]]
#   ],
#   secret_key_base: secret_key_base
