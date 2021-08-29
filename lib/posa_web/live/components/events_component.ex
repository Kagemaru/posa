defmodule PosaWeb.EventsComponent do
  use PosaWeb, :live_component

  def render(assigns) do
    ~L"""
    <%= live_component @socket,
                       PosaWeb.EventComponent, event(assigns.data)

                      #  icon: :question,
                      #  button: %{text: "Details", link: "https://www.google.com"},
                      #  title: "Title #{i}",
                      #  content: [%{title: "Author", text: "Johnny #{i}"}, %{title: "Test", text: "Lorem Ipsum"}],
                      #  user: %{text: "olibrian", link: "https://www.google.com"},
                      #  repo: %{text: "hitobito/hitobito_die_mitte", link: "https://www.google.com"}

    %>
    """
  end

  defp event(%{type: "IssuesEvent"} = event) do
    # require IEx
    # IEx.pry()
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

  defp event(event) do
    %{
      icon: :question,
      title: "Event",
      content: [],
      user: %{text: event.actor.display_login, link: url(event.actor.url)},
      repo: %{text: event.repo.name, link: url(event.repo.url)}
    }
  end

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
