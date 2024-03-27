defmodule PosaWeb.EventComponents do
  @moduledoc "Provides UI components for events."

  use PosaWeb, :html

  # Public API {{{

  def event(assigns) do
    component_name = component_name(assigns.event.type)

    if function_exported?(__MODULE__, component_name, 1) do
      apply(__MODULE__, component_name, [assigns])
    else
      apply(__MODULE__, :base_event, [assigns])
    end
  end

  # /Public API }}}

  # Components {{{

  ## Base Event Component {{{

  @doc """
  Renders an  event.

  ## Examples
    <.event icon="fa-comments">
      <:title>"Title"</:title>
      <:link href>
        <.link href="https://example.com">"Link"</.link>
      </:extra>
      <:content label="Commits">20</:content>
      <:content label="Comment">Test</:content>
      <:footer label="Element"><p>Element 1</p></:footer>
      <:footer link="https://example.com"><p>Element 2</p></:footer>
      <:footer><p>Element 3</p></:footer>
    </.event>

  """
  ## Attrs/Slots {{{
  attr :icon, :string,
    default: "fa-asterisk",
    examples: ["fa-lock-open", "fa-comments", "fa-arrow-down"],
    doc: "A FontAwesome icon from https://fontawesome.com/icons"

  slot :title, doc: "Title of the event"

  slot :link, doc: "Link in the header" do
    attr :href, :string, required: true, doc: "Link href"
  end

  slot :content, doc: "The main content of the event" do
    attr :label, :string, doc: "Content entry label"
  end

  slot :footer, doc: "The footer elements of the event" do
    attr :label, :string, doc: "Footer entry label"
    attr :link, :string, doc: "Footer entry link href"
  end

  ## Attrs/Slots }}}
  def base_event(assigns) do
    assigns = assign(assigns, link: List.first(assigns.link))

    ~H"""
    <article class="z-10 flex flex-col">
      <header class="flex flex-row items-center flex-none h-12 gap-2 px-3 py-1 font-semibold border rounded-tr-2xl bg-pz-carolina-blue border-pz-dark-blue">
        <.icon
          :if={@icon}
          name={@icon}
          class="flex items-center justify-center flex-grow-0 flex-shrink ml-1 mr-2 text-lg text-pz-prussian-blue"
        />
        <h3 class="flex-grow flex-shrink-0 text-lg">
          <%= render_slot(@title) || component_name(@event.type) %>
        </h3>
        <div :if={@link} class="flex-grow-0 flex-shrink">
          <.link
            href={@link.href}
            class="px-3 py-1 mr-2 font-bold bg-white border rounded-lg cursor-pointer text-pz-prussian-blue border-pz-prussian-blue"
          >
            <%= render_slot(@link) %>
          </.link>
        </div>
      </header>

      <dl
        :for={entry <- @content}
        class="p-2 overflow-hidden border-l border-r bg-blue-50 border-pz-prussian-blue"
      >
        <dt :if={entry.label} class="inline mr-2 font-semibold text-pz-dark-blue">
          <%= entry.label %>
        </dt>
        <dd class="inline"><%= render_slot(entry) %></dd>
      </dl>

      <footer class="flex flex-row items-center justify-between h-12 px-3 py-1 border rounded-bl-2xl bg-pz-carolina-blue border-pz-dark-blue">
        <.container :for={entry <- @footer} entry={entry} />
      </footer>
    </article>
    """
  end

  attr :entry, :map, required: true, doc: "Footer entry"

  defp container(assigns) do
    ~H"""
    <div class="flex-none">
      <span :if={@entry.label} class="mr-1 font-semibold text-pz-prussian-blue">
        <%= @entry.label %>
      </span>
      <%= if @entry.link do %>
        <.link href={@entry.link} class="text-white underline"><%= render_slot(@entry) %></.link>
      <% else %>
        <%= render_slot(@entry) %>
      <% end %>
    </div>
    """
  end

  ## /Base Event Component }}}
  ## PublicEvent {{{

  def public_event(assigns) do
    ~H"""
    <.base_event icon="fa-lock-open">
      <:title>Repo publiziert</:title>
    </.base_event>
    """
  end

  ## /PublicEvent }}}
  ## PullRequestReviewCommentEvent {{{

  attr :event, :map, required: true, doc: "Event"

  def pull_request_review_comment_event(assigns) do
    comment = assigns.event.payload.comment

    assigns =
      assign(
        assigns,
        url: github_url(comment.html_url),
        author: comment.user.login,
        comment: markdown(comment.body)
      )

    ~H"""
    <.base_event icon="fa-comments">
      <:title>Review kommentiert</:title>
      <:link href={@url}>Details</:link>
      <:content label="Author"><%= @author %></:content>
      <:content label="Kommentar"><%= @comment %></:content>
    </.base_event>
    """
  end

  ## /PullRequestReviewCommentEvent }}}
  ## PullRequestReviewEvent {{{

  attr :event, :map, required: true, doc: "Event"

  def pull_request_review_event(assigns) do
    review = assigns.event.payload.review

    assigns =
      assign(
        assigns,
        url: github_url(review.html_url),
        reviewer: review.user.login,
        evaluation: review.state,
        comment: markdown(review.body)
      )

    ~H"""
    <.base_event icon="fa-arrow-down">
      <:title>Pull Request durchgesehen</:title>
      <:link href={@url}>Details</:link>
      <:content label="Reviewer"><%= @reviewer %></:content>
      <:content label="Bewertung"><%= @evaluation %></:content>
      <:content label="Kommentar"><%= @comment %></:content>
    </.base_event>
    """
  end

  ## /PullRequestReviewEvent }}}
  ## ReleaseEvent {{{

  attr :event, :map, required: true, doc: "Event"

  def release_event(assigns) do
    release = assigns.event.payload.release

    assigns =
      assign(
        assigns,
        url: github_url(release.html_url),
        author: release.author.login,
        description: markdown(release.body)
      )

    ~H"""
    <.base_event icon="fa-archive">
      <:title>Release erstellt</:title>
      <:link href={@url}>Details</:link>
      <:content label="Author"><%= @author %></:content>
      <:content label="Beschreibung"><%= @description %></:content>
    </.base_event>
    """
  end

  ## /ReleaseEvent }}}
  ## ForkEvent {{{

  attr :event, :map, required: true, doc: "Event"

  def fork_event(assigns) do
    forkee = assigns.event.payload.forkee

    assigns =
      assign(
        assigns,
        url: github_url(forkee.html_url),
        owner: forkee.owner.login,
        repo: forkee.name
      )

    ~H"""
    <.base_event icon="fa-code-branch">
      <:title>Fork erstellt</:title>
      <:link href={@url}>Details</:link>
      <:content label="Besitzer"><%= @owner %></:content>
      <:content label="Neues Repo"><%= @repo %></:content>
    </.base_event>
    """
  end

  ## /ForkEvent }}}
  ## WatchEvent {{{

  def watch_event(assigns) do
    ~H"""
    <.base_event icon="fa-eye">
      <:title>Neuer Beobachter</:title>
    </.base_event>
    """
  end

  ## /WatchEvent }}}
  ## CreateEvent {{{

  attr :event, :map, required: true, doc: "Event"

  def create_event(assigns) do
    assigns =
      assign(
        assigns,
        description: assigns.event.payload.description,
        default_branch: assigns.event.payload.master_branch
      )

    ~H"""
    <.base_event icon="fa-plus">
      <:title>Repository erstellt</:title>
      <:content label="Beschreibung"><%= @description %></:content>
      <:content label="DefaultBranch"><%= @default_branch %></:content>
    </.base_event>
    """
  end

  ## /CreateEvent }}}
  ## DeleteEvent {{{

  def delete_event(assigns) do
    ~H"""
    <.base_event icon="fa-trash-alt">
      <:title>Branch gelöscht</:title>
    </.base_event>
    """
  end

  ## /DeleteEvent }}}
  ## PullRequestEvent {{{

  attr :event, :map, required: true, doc: "Event"

  def pull_request_event(assigns) do
    pr = assigns.event.payload.pull_request

    assigns =
      assign(
        assigns,
        url: github_url(pr.html_url),
        author: pr.user.login,
        message: pr.title,
        changes: git_changes(pr.commits, pr.additions, pr.deletions),
        base: pr.base.label,
        head: pr.head.label
      )

    ~H"""
    <.base_event icon="fa-arrow-down">
      <:title>Pull Request erstellt</:title>
      <:link href={@url}>Details</:link>
      <:content label="Author"><%= @author %></:content>
      <:content label="Message"><%= @message %></:content>
      <:content label="Changes"><%= @changes %></:content>
      <:content label="Base"><%= @base %></:content>
      <:content label="Head"><%= @head %></:content>
    </.base_event>
    """
  end

  ## /PullRequestEvent }}}
  ## PushEvent {{{

  attr :event, :map, required: true, doc: "Event"

  def push_event(assigns) do
    event = assigns.event
    commits = event.payload.commits
    commit_messages = Enum.map_join(commits, "\n", &"- #{&1.message}")
    commit_url = Enum.find_value(commits, & &1[:url])

    assigns =
      assign(
        assigns,
        url: commit_url && github_url(commit_url),
        user: event.actor.display_login,
        commits: event.payload.size,
        range: "#{sha(event.payload.before)}...#{sha(event.payload.head)}",
        messages: Enum.any?(commits) && markdown(commit_messages)
      )

    ~H"""
    <.base_event icon="fa-arrow-up">
      <:title>Commits gepusht</:title>
      <:link href={@url}>Details</:link>
      <:content label="User"><%= @user %></:content>
      <:content label="Commits"><%= @commits %></:content>
      <:content label="Range"><%= @range %></:content>
      <:content label="Messages"><%= @messages || "Keine Commits" %></:content>
    </.base_event>
    """
  end

  ## /PushEvent }}}
  ## IssuesCommentEvent {{{

  attr :event, :map, required: true, doc: "Event"

  def issues_comment_event(assigns) do
    event = assigns.event
    comment = event.payload.comment
    actor = event.actor
    repo = event.repo

    assigns =
      assign(
        assigns,
        url: github_url(comment.html_url),
        author: comment.user.login,
        comment: markdown(comment.body),
        username: actor.display_login,
        userlink: github_url(actor.url),
        reponame: repo.name,
        repolink: github_url(repo.url)
      )

    ~H"""
    <.base_event icon="fa-comments">
      <:title>Issue kommentiert</:title>
      <:link href={@url}>Details</:link>
      <:content label="Author"><%= @author %></:content>
      <:content label="Kommentar"><%= @comment %></:content>
      <:footer label="User:" link={@userlink}><%= @username %></:footer>
      <:footer label="Repo:" link={@repolink}><%= @reponame %></:footer>
    </.base_event>
    """
  end

  ## /IssuesCommentEvent }}}
  ## IssuesEvent {{{

  attr :event, :map, required: true, doc: "Event"

  def issues_event(assigns) do
    event = assigns.event
    issue = event.payload.issue
    actor = event.actor
    repo = event.repo

    assigns =
      assign(
        assigns,
        url: github_url(issue.html_url),
        author: issue.user.login,
        title: issue.title,
        comment: markdown(issue.body),
        username: actor.display_login,
        userlink: github_url(actor.url),
        reponame: repo.name,
        repolink: github_url(repo.url)
      )

    ~H"""
    <.base_event icon="fa-exclamation">
      <:title>Issue erstellt</:title>
      <:link href={@url}>Details</:link>
      <:content label="Author"><%= @author %></:content>
      <:content label="Titel"><%= @title %></:content>
      <:content label="Kommentar"><%= @comment %></:content>
      <:footer label="User:" link={@userlink}><%= @username %></:footer>
      <:footer label="Repo:" link={@repolink}><%= @reponame %></:footer>
    </.base_event>
    """
  end

  ## /IssuesEvent }}}

  # /Components }}}

  # Helpers {{{
  defp component_name(name) do
    name |> Phoenix.Naming.underscore() |> String.to_atom()
  end

  defp sha(commit_sha), do: commit_sha |> String.slice(0, 6)

  defp github_url(nil), do: ""

  defp github_url(url) do
    url
    |> String.replace("api.github.com", "github.com")
    |> String.replace(["users/", "repos/"], "")
  end

  defp markdown(text, opts \\ [])
  defp markdown(nil, _), do: ""

  defp markdown(text, opts) when is_binary(text) do
    defaults = [
      code_class_prefix: "language-",
      compact_output: true,
      gfm_tables: true
    ]

    options = Earmark.Options.make_options!(defaults ++ opts)

    case Earmark.as_html(text, options) do
      {:ok, html, _} ->
        raw(html)

      {:error, html, errors} ->
        error_output =
          for {type, num, error} <- errors do
            "#{type} ##{num}: #{error}"
          end
          |> Enum.join("\n")

        raw("<pre><!-- markdown had errors:\n #{error_output}--></pre>\n#{html}")
    end
  end

  defp markdown(text, _), do: text

  defp git_changes(commits, additions, deletions, display_limit \\ 20) do
    factor = max((additions + deletions) / display_limit, 1.0)

    adds = String.duplicate("+", calculate_change(additions, factor))
    dels = String.duplicate("-", calculate_change(deletions, factor))

    markdown(
      """
      <span class="text-green">#{adds}</span>
      <span class="text-red">#{dels}</span>
      - #{commits} Commits
      - #{additions} Additions
      - #{deletions} Deletions
      """,
      escape: false
    )
  end

  defp calculate_change(value, factor) do
    (value / factor) |> Float.ceil() |> Kernel.trunc()
  end

  # /Helpers }}}
end
