defmodule Posa.Github.API.Client do
  @moduledoc """
  This module is responsible for the communication with the Github API.
  """

  alias Posa.Github.API.Etag
  alias Posa.Github.API.Links
  alias Posa.Github.API.PaginatingAdapter

  def new do
    Req.new()
    |> Etag.attach()
    |> Links.attach()
    |> Req.merge(
      adapter: &PaginatingAdapter.run_finch/1,
      base_url: "https://api.github.com",
      etags: true,
      github_links: true,
      headers: %{
        authorization: "token #{token()}",
        user_agent: "POSA"
      },
      max_retries: 10,
      retry_delay: &retry_delay/1
    )
  end

  defp retry_delay(n) when n in 0..2, do: 1_000
  defp retry_delay(n) when n in 3..5, do: 10_000
  defp retry_delay(n) when n in 6..8, do: 100_000
  defp retry_delay(_), do: 1_000_000

  defp token, do: Application.fetch_env!(:posa, :github_token)
end
