defmodule Posa.GithubApi.Client do
  @moduledoc """
  This module is responsible for the communication with the Github API.
  """

  alias Posa.GithubApi.{Etag, Links, Paginate}

  def organizations do
    for org <- orgs() do
      new()
      |> Req.get(url: "/orgs/#{org}")

      # TODO: accumulate results
    end
  end

  def new do
    Req.new()
    |> Etag.attach()
    |> Req.merge(etags: true)
    |> Links.attach()
    |> Req.merge(github_links: true)
    |> Req.merge(base_url: "https://api.github.com")
    |> Req.merge(headers: %{user_agent: "POSA"})
    |> Req.merge(headers: %{authorization: "token #{token()}"})
    |> Req.merge(max_retries: 10)
    |> Req.merge(retry_delay: &retry_delay/1)
  end

  def retry_delay(count) do
    case count do
      0..2 -> 1_000
      3..5 -> 10_000
      6..8 -> 100_000
      _ -> 1_000_000
    end
  end

  def token, do: Application.fetch_env(:posa, :github_token)
  def orgs, do: Application.fetch_env(:posa, :organizations)
end
