defmodule PosaWeb.EventComponent do
  @moduledoc "This cdomponent handles the display of events"

  use PosaWeb, :live_component

  def mount(socket) do
    {:ok,
     assign(
       socket,
       icon: nil,
       button: nil,
       title: nil,
       user: nil,
       repo: nil
     )}
  end

  def update(assigns, socket) do
    socket = assign(socket, assigns)

    socket = assign(socket, icon: icon(socket.assigns.icon))

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
      <section class="flex flex-col bg-blue-50">
        <header class="flex flex-row items-center flex-none h-12 px-3 py-1 font-semibold bg-blue-300 rounded-tr-2xl">
          <%= if @icon != nil do %>
            <div class="flex-grow-0 w-1 h-6 mr-2 text-lg flex-shrink-1"><%= @icon %></div>
          <% end %>
          <%= if @title != nil do %>
            <div class="flex-shrink-0 text-lg flex-grow-1"><%= @title %></div>
          <% end %>
          <%= if @button != nil do %>
            <div class="flex-grow-0 flex-shrink-1">
              <button class="px-2 mr-2 font-bold bg-blue-200 rounded-lg cursor-pointer"><%= @button.text %></button>
            </div>
          <% end %>
        </header>
        <%= if @content != nil do %>
          <dl class="p-2">
            <%= for item <- @content do %>
              <dt class="inline font-semibold text-light-blue-500"><%= item.title %></dt>
              <dd class="inline"><%= item.text %></dd>
              <br />
            <% end %>
          </dl>
        <% end %>
        <footer class="flex flex-row items-center h-12 px-3 py-1 bg-blue-300 rounded-bl-2xl">
          <%= if @user != nil do %>
            <div class="flex-1">
              <span class="font-semibold text-gray-100">User:</span>
              <a href="<%= @user.link %>" class="text-white underline"><%= @user.text %></a>
            </div>
          <% end %>
          <%= if @repo != nil do %>
            <div class="flex-1">
              <span class="font-semibold text-gray-100">Repo:</span>
              <a href="<%= @repo.link %>" class="text-white underline"><%= @repo.text %></a>
            </div>
          <% end %>
        </footer>
      </section>
    """
  end

  defp icon(:exclamation), do: "!"
  defp icon(:question), do: "?"
  defp icon(_), do: nil
end
