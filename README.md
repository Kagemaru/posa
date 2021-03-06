![Tests](https://github.com/Kagemaru/posa/workflows/Elixir%20Tests/badge.svg?branch=master)
![Style Checks](https://github.com/Kagemaru/posa/workflows/Elixir%20Style%20Checks/badge.svg?branch=master)

# Posa

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## Build and Run via Docker

The secret_key_base needs to be changed. It would compile, but it would break
upon running. This is intentional, set your own, secret, secret_key_base and
keep it basically secret.

Other than that, here you go:

	docker build . --build-arg secret_key_base=AtLeast64BytesOfRandomCharacters -t posa:latest
	docker run -p 4000:4000 posa:latest
