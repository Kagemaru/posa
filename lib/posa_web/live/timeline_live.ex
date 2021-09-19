defmodule PosaWeb.TimelineLive do
  @moduledoc false

  use PosaWeb, :live_view

  alias Posa.Github
  alias Posa.Github.Data

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Github.subscribe()

    socket =
      socket
      |> assign(events: list_events())
      |> assign(last_updated: DateTime.now!("Europe/Zurich"))

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <div class="flex flex-row px-4 pt-4 ml-3 overflow-auto">
      <div class="absolute right-0 mr-10">Last update: <%= @last_updated |> DateTime.to_string %></div>
      <%= live_component @socket, PosaWeb.TimelineComponent, events: @events %>
    </div>
    """
  end

  @impl true
  def handle_info({"synced", last_update}, socket) do
    socket =
      socket
      |> assign(events: list_events())
      |> assign(last_updated: last_update)

    {:noreply, socket}
  end

  def list_events do
    Data.list_events() |> deep_atomize_keys
  end

  def deep_atomize_keys(data) when is_list(data) do
    for(item <- data, do: deep_atomize_keys(item))
  end

  def deep_atomize_keys(data) when is_struct(data), do: data

  def deep_atomize_keys(data) when is_map(data) do
    for {key, val} <- data, into: %{}, do: {atomize(key), deep_atomize_keys(val)}
  end

  def deep_atomize_keys(data), do: data

  defp atomize(key) when is_binary(key), do: String.to_atom(key)
  defp atomize(key) when is_atom(key), do: key
end
