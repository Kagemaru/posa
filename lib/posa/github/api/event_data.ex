defmodule Posa.Github.API.EventData do
  @moduledoc """
  API Interface for the Github Events
  """

  def transform(event) do
    %{
      id: event["id"],
      actor: actor(event["actor"]),
      repo: repo(event["repo"]),
      org: org(event["org"]),
      payload: payload(event),
      created_at: event["created_at"],
      public: event["public"],
      type: event["type"]
    }
  end

  defp actor(actor) do
    %{
      login: actor["login"],
      display_login: actor["display_login"],
      url: actor["url"]
    }
  end

  defp repo(repo) do
    %{
      # id: repo["id"],
      name: repo["name"],
      url: repo["url"]
    }
  end

  defp org(_org) do
    %{
      # id: org["id"],
      # login: org["login"],
      # gravatar_id: org["gravatar_id"],
      # url: org["url"],
      # avatar_url: org["avatar_url"]
    }
  end

  defp payload(event) do
    payload = event["payload"]

    %{
      before: payload["before"],
      comment: %{
        html_url: payload["comment"]["html_url"],
        user: %{login: payload["comment"]["user"]["login"]},
        body: payload["comment"]["body"]
      },
      commits: commits(payload["commits"] || []),
      description: payload["description"],
      forkee: %{
        html_url: payload["forkee"]["html_url"],
        owner: %{login: payload["forkee"]["owner"]["login"]},
        name: payload["forkee"]["name"]
      },
      head: payload["head"],
      issue: %{
        html_url: payload["issue"]["html_url"],
        user: %{login: payload["issue"]["user"]["login"]},
        title: payload["issue"]["title"],
        body: payload["issue"]["body"]
      },
      master_branch: payload["master_branch"],
      pull_request: %{
        html_url: payload["pull_request"]["html_url"],
        user: %{login: payload["pull_request"]["user"]["login"]},
        title: payload["pull_request"]["title"],
        commits: payload["pull_request"]["commits"],
        additions: payload["pull_request"]["additions"],
        deletions: payload["pull_request"]["deletions"],
        base: %{label: payload["pull_request"]["base"]["label"]},
        head: %{label: payload["pull_request"]["head"]["label"]}
      },
      release: %{
        html_url: payload["release"]["html_url"],
        author: %{login: payload["release"]["author"]["login"]},
        body: payload["release"]["body"]
      },
      review: %{
        html_url: payload["review"]["html_url"],
        user: %{login: payload["review"]["user"]["login"]},
        state: payload["review"]["state"],
        body: payload["review"]["body"]
      },
      size: payload["size"]
    }
  end

  defp commits(commits) do
    commits
    |> Enum.map(fn commit ->
      %{
        message: commit["message"],
        url: commit["url"]
      }
    end)
  end
end
