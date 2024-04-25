defmodule PosaWeb.EventsComponent do
  alias Posa.Github.Event

  import PosaWeb.EventComponents, only: [event: 1]
  use PosaWeb, :live_component

  def mount(socket) do
    socket = assign(socket, events: [], expanded: MapSet.new())

    {:ok, socket}
  end

  def update(assigns, socket) do
    socket =
      socket
      |> assign(
        id: assigns.id,
        events: Event.list_by_day!(%{day: assigns.day})
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id={@id} class="flex flex-col gap-4">
      <.event :for={event <- @events} event={event} expanded={@expanded} phx_target={@myself} />
    </div>
    """
  end

  def handle_event("toggle_expand", %{"id" => id}, socket) do
    expanded = socket.assigns.expanded
    id = String.to_integer(id)

    expanded =
      if MapSet.member?(expanded, id) do
        MapSet.delete(expanded, id)
      else
        MapSet.put(expanded, id)
      end

    {:noreply, assign(socket, expanded: expanded)}
  end
end
