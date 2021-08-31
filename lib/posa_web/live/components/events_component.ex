defmodule PosaWeb.EventsComponent do
  use PosaWeb, :live_component

  def render(assigns) do
    ~L"""
    <%= live_component @socket,
                       PosaWeb.EventComponent,
                       event(@data)

    %>
    """
  end

  defp event(event) do
    parameters = type(event) || %{}

    Map.merge(parameters, %{event: event})
  end

  defp type(%{type: "WatchEvent"} = _event) do
    %{
      icon: "fa-eye",
      title: "Neuer Beobachter"
    }
  end

  defp type(%{type: "CreateEvent"} = event) do
    %{
      icon: "fa-plus",
      title: "Repository erstellt",
      content: [
        %{title: "Beschreibung", text: event.payload.description},
        %{title: "Master Branch", text: event.payload.master_branch}
      ]
    }
  end

  defp type(%{type: "DeleteEvent"} = _event) do
    %{
      icon: "fa-trash-alt",
      title: "Branch gelöscht"
    }
  end

  defp type(%{type: "PullRequestEvent"} = event) do
    pr = event.payload.pull_request

    %{
      content: [
        %{title: "Author", text: pr.user.login},
        %{title: "Message", text: pr.title},
        %{title: "Additions", text: pr.additions},
        %{title: "Deletions", text: pr.deletions},
        %{title: "Commits", text: pr.commits},
        %{title: "Base", text: pr.base.label},
        %{title: "Head", text: pr.head.label}
      ],
      button: %{text: "Details", link: url(pr.html_url)}
    }
  end

  defp type(%{type: "PushEvent"} = event) do
    commits = event.payload.commits
    commit = List.first(commits)

    %{
      icon: "fa-arrow-up",
      title: "Commits gepusht",
      content: [
        %{title: "User", text: event.actor.login},
        %{title: "Commits", text: event.payload.size},
        %{title: "Message", text: commit.message}
      ],
      button: %{text: "Details", link: url(commit.url)}
    }
  end

  defp type(%{type: "IssueCommentEvent"} = event) do
    comment = event.payload.comment

    %{
      icon: "fa-comments",
      title: "Issue kommentiert",
      content: [
        %{title: "Author", text: comment.user.login},
        %{title: "Kommentar", text: comment.body}
      ],
      button: %{text: "Details", link: url(comment.html_url)},
      user: %{text: event.actor.display_login, link: url(event.actor.url)},
      repo: %{text: event.repo.name, link: url(event.repo.url)}
    }
  end

  defp type(%{type: "IssuesEvent"} = event) do
    issue = event.payload.issue

    %{
      icon: "fa-exclamation",
      title: "Issue erstellt",
      content: [
        %{title: "Author", text: issue.user.login},
        %{title: "Titel", text: issue.title},
        %{title: "Kommentar", text: markdown(issue.body)}
      ],
      button: %{text: "Details", link: url(issue.html_url)},
      user: %{text: event.actor.display_login, link: url(event.actor.url)},
      repo: %{text: event.repo.name, link: url(event.repo.url)}
    }
  end

  defp type(%{type: type} = event) do
    IO.inspect(type, label: 'type')
    %{
      icon: "fa-asterisk",
      title: type,
      content: [],
      user: %{text: event.actor.display_login, link: url(event.actor.url)},
      repo: %{text: event.repo.name, link: url(event.repo.url)}
    }
  end

  # HACK: Duplication
  defp url(url) do
    url
    |> String.replace("api.github.com", "github.com")
    |> String.replace(["users/", "repos/"], "")
  end

  defp markdown(nil), do: ""

  defp markdown(text) when is_binary(text) do
    {:ok, html, _} = Earmark.as_html(text, compact_output: true)

    raw(html)
  end

  defp markdown(text), do: text |> IO.inspect(label: 'No markdown')
end
