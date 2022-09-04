defmodule PosaWeb.EventComponent do
  @moduledoc "This component handles the display of events"

  use PosaWeb, :live_component

  def mount(socket) do
    {:ok,
     assign(
       socket,
       icon: "fa-asterisk",
       button: nil,
       title: nil,
       content: []
     )}
  end

  def update(assigns, socket) do
    socket = assign(socket, assigns)

    actor = assigns.event.actor
    erepo = assigns.event.repo
    user = Map.get(assigns, :user, %{text: actor.display_login, link: url(actor.url)})
    repo = Map.get(assigns, :repo, %{text: erepo.name, link: url(erepo.url)})

    socket =
      assign(
        socket,
        user: user,
        repo: repo
      )

    {:ok, socket}
  end

  # HACK: Duplication
  defp url(url) do
    url
    |> String.replace("api.github.com", "github.com")
    |> String.replace(["users/", "repos/"], "")
  end

  def render(assigns) do
    ~H"""
      <section class="event" data-type={@event.type}>
        <header class="event__header">
          <%= if @icon != nil do %>
            <i class="event__icon fas #{@icon}"></i>
          <% end %>
          <div class="event__title"><%= @title || @event.type %></div>
          <%= if @button != nil do %>
            <div class="event__button">
              <a href={@button.link} class="event__button-link"><%= @button.text %></a>
            </div>
          <% end %>
        </header>
        <%= if @content != nil && @content != [] do %>
          <dl class="event__content">
            <%= for item <- @content do %>
              <dt class="event__topic"><%= item.title %></dt>
              <dd class="event__detail"><%= item.text %></dd>
              <br />
            <% end %>
          </dl>
        <% end %>
        <footer class="event__footer">
          <%= if @user != nil do %>
            <div class="event__footer-container">
              <span class="event__footer-title">User:</span>
              <a href={@user.link || url(@event.actor.url)} class="event__footer-value">
                <%= @user.text || @event.actor.display_login %>
              </a>
            </div>
          <% end %>
          <%= if @repo != nil do %>
            <div class="event__footer-container">
              <span class="event__footer-title">Repo:</span>
              <a href={@repo.link || url(@event.repo.url)} class="event__footer-value">
                <%= @repo.text || @event.repo.name %>
              </a>
            </div>
          <% end %>
        </footer>
      </section>
    """
  end
end
