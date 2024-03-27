defmodule PosaWeb.TimelineLive do
  @moduledoc """
  Liveview that displays the timeline of events.
  """

  use PosaWeb, :live_view

  alias Posa.Github
  alias Posa.Github.Data
  import PosaWeb.TimelineComponents, only: [timeline: 1, month_group: 1, day_group: 1]
  import PosaWeb.EventComponents, only: [event: 1]

  @impl true
  def mount(_params, _session, socket) do
    Github.subscribe()

    debug = debug()

    socket =
      socket
      |> assign(
        debug: debug,
        events: list_events(),
        last_updated: DateTime.now!("Europe/Zurich")
      )

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.debug_tools :if={@debug.enabled} debug={@debug} />
    <div class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-[120rem]">
        <div class="flex flex-col px-4 pt-24 ml-3 overflow-x-hidden overflow-y-scroll">
          <.timeline events={@events}>
            <:month :let={month}>
              <.month_group open={month.index == 0} days={month.days}>
                <:day :let={day}>
                  <.day_group open={day.index == 0} events={day.events}>
                    <:event :let={event}>
                      <.event event={event} />
                    </:event>
                  </.day_group>
                </:day>
              </.month_group>
            </:month>
          </.timeline>

          <%!-- <.live_component module={PosaWeb.TimelineComponent} id="timeline-lv" events={@events} /> --%>
        </div>
      </div>
    </div>
    """
  end

  attr :debug, :map, default: %{}, doc: "Debugging information"

  def debug_tools(assigns) do
    ~H"""
    <div id="debug-helpers" class="fixed z-50 flex flex-col gap-4 right-4 top-4 min-w-48">
      <.button phx-click="sync_now">Sync Now</.button>
      <ul class="p-4 border rounded-lg bg-slate-200 border-slate-600">
        <li class="flex justify-between">
          <span>Next:</span>
          <time datetime={@debug.time}>
            <%= (@debug.time && "#{div(@debug.time, 1000)} s") || "off" %>
          </time>
        </li>
      </ul>
      <.button phx-click="update_sync_timer">Update Timer & Stats</.button>
      <.button disabled={!@debug.time} phx-click="cancel_sync_timer">Cancel Sync Timer</.button>
      <.button disabled={!!@debug.time} phx-click="start_sync_timer">Start Sync Timer</.button>
      <ul class="p-4 border rounded-lg bg-slate-200 border-slate-600">
        <li class="flex justify-between"><span>Organizations:</span><%= @debug.stats.orgs %></li>
        <li class="flex justify-between"><span>Users:</span><%= @debug.stats.users %></li>
        <li class="flex justify-between"><span>Events:</span><%= @debug.stats.events %></li>
      </ul>
    </div>
    """
  end

  @impl true
  def handle_event("update_sync_timer", _, socket) do
    {:noreply, assign(socket, debug: debug())}
  end

  @impl true
  def handle_event("cancel_sync_timer", _, socket) do
    Posa.Sync.cancel_timer()

    {:noreply, assign(socket, debug: debug())}
  end

  @impl true
  def handle_event("start_sync_timer", _, socket) do
    Posa.Sync.set_timer()

    {:noreply, assign(socket, debug: debug())}
  end

  @impl true
  def handle_event("sync_now", _, socket) do
    Posa.Sync.run_sync()

    {:noreply, socket}
  end

  @impl true
  def handle_info({"synced", last_update}, socket) do
    socket =
      socket
      |> assign(events: list_events())
      |> assign(last_updated: last_update)

    {:noreply, socket}
  end

  def list_events, do: Data.list_events() |> deep_atomize_keys

  # TODO: Move tooling to it's own module
  # credo:disable-for-previous-line
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

  defp debug do
    %{
      enabled: Application.fetch_env!(:posa, :debug),
      time: Posa.Sync.get_time(),
      stats: %{
        orgs: Data.count_orgs(),
        users: Data.count_users(),
        events: Data.count_events()
      }
    }
  end
end
