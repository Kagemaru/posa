defmodule PosaWeb.EventsComponent do
  use PosaWeb, :live_component

  def render(assigns) do
    ~L"<%= live_component @socket, PosaWeb.EventComponent, event(@data) %>"
  end

  defp event(event) do
    Map.merge(type(event), %{event: event})
  end

  defp type(%{type: "PublicEvent"} = _event) do
    %{
      icon: "fa-lock-open",
      title: "Repo publiziert"
    }
  end

  defp type(%{type: "PullRequestReviewCommentEvent"} = event) do
    comment = event.payload.comment

    %{
      icon: "fa-comments",
      title: "Review kommentiert",
      content: [
        %{title: "Author", text: comment.user.login},
        %{title: "Kommentar", text: markdown(comment.body)}
      ],
      button: %{text: "Details", link: url(comment.html_url)}
    }
  end

  defp type(%{type: "PullRequestReviewEvent"} = event) do
    review = event.payload.review

    %{
      icon: "fa-arrow-down",
      title: "Pull Request durchgesehen",
      content: [
        %{title: "Reviewer", text: review.user.login},
        %{title: "Bewertung", text: review.state},
        %{title: "Kommentar", text: markdown(review.body)}
      ],
      button: %{text: "Details", link: url(review.html_url)}
    }
  end

  defp type(%{type: "ReleaseEvent"} = event) do
    release = event.payload.release

    %{
      icon: "fa-archive",
      title: "Release erstellt",
      content: [
        %{title: "Author", text: release.author.login},
        %{title: "Beschreibung", text: markdown(release.body)}
      ],
      button: %{text: "Details", link: url(release.html_url)}
    }
  end

  defp type(%{type: "ForkEvent"} = event) do
    forkee = event.payload.forkee
    owner = forkee.owner.login

    %{
      icon: "fa-code-branch",
      title: "Fork erstellt",
      content: [
        %{title: "Besitzer", text: owner},
        %{title: "Neues Repo", text: forkee.name}
      ],
      button: %{text: "Details", link: url(forkee.git_url)}
    }
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
        %{title: "Default Branch", text: event.payload.master_branch}
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
      icon: "fa-arrow-down",
      title: "Pull Request erstellt",
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
    commit_messages = commits |> Enum.map(fn c -> "- #{c.message}" end) |> Enum.join("\n")
    commit_url = commits |> Enum.map(fn c -> c.url end) |> Enum.reject(fn c -> is_nil(c) end) |>List.first

    message =
      if List.first(commit) do
        markdown(commit_messages)
      else
        "Keine Commits"
      end

    button =
      if List.first(commit) do
        %{text: "Details", link: url(commit.url)}
      else
        nil
      end

    %{
      icon: "fa-arrow-up",
      title: "Commits gepusht",
      content: [
        %{title: "User", text: event.actor.login},
        %{title: "Commits", text: event.payload.size},
        %{title: "Range", text: "#{sha(event.payload.before)}...#{sha(event.payload.head)}"},
        %{title: "Messages", text:  message)}
      ],
      button: button
    }
  end

  defp type(%{type: "IssueCommentEvent"} = event) do
    comment = event.payload.comment

    %{
      icon: "fa-comments",
      title: "Issue kommentiert",
      content: [
        %{title: "Author", text: comment.user.login},
        %{title: "Kommentar", text: markdown(comment.body)}
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

  defp type(_), do: %{}

  # HACK: Duplication
  defp url(url) do
    url
    |> String.replace("api.github.com", "github.com")
    |> String.replace(["users/", "repos/"], "")
  end

  defp markdown(nil), do: ""

  defp markdown(text) when is_binary(text) do
    {:ok, html, _} =
      Earmark.as_html(text, %Earmark.Options{
        code_class_prefix: "language-",
        compact_output: true,
        gfm_tables: true
      })

    raw(html)
  end

  defp markdown(text), do: text

  defp sha(commit_sha), do: commit_sha |> String.slice(0, 6)
end
