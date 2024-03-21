![Tests](https://github.com/Kagemaru/posa/workflows/Elixir%20Tests/badge.svg?branch=master)
![Style Checks](https://github.com/Kagemaru/posa/workflows/Elixir%20Style%20Checks/badge.svg?branch=master)

# Posa

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

On fresh installations, it will complain about a missing SECRET_KEY_BASE and
PHX_GITHUB_TOKEN, but provide some pointers about how to get those.

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

## Updating Elixir

If you update the elixir-version, please follow the following steps:

- update `.tool-versions`
- check app and dependencies
- run `openshift/bin/update-build-image`
- commit `Dockerfile` and changed Openshift-YAMLs
- push changes
- apply the openshift-config
- maybe check the imagestream and start a build (may be done automatically)
