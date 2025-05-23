defmodule PosaWeb.TimelineLive do
  @moduledoc """
  Liveview that displays the timeline of events.
  """

  alias Posa.Github.Statistic
  alias Posa.Github.Organization
  alias Posa.Github.User
  alias Posa.Github.Event

  use PosaWeb, :live_view

  import PosaWeb.TimelineComponent, only: [timeline: 1]

  @impl true
  def mount(_params, _session, socket) do
    months = Event.months!()
    days = Event.days!(%{group: true})
    stats = Statistic.as_map!()
    open = initial_open(months)

    socket = assign(socket, debug: debug(), months: months, days: days, stats: stats, open: open)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Posa.PubSub, "github:sync")
      Phoenix.PubSub.subscribe(Posa.PubSub, "github:stats")
    end

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.debug_tools :if={@debug.enabled} debug={@debug} />
    <div class="px-4 py-20 sm:px-6 lg:px-8">
      <div class="mx-auto max-w-[120rem]">
        <div class="flex flex-col px-4 pt-24 ml-3 overflow-hidden">
          <.timeline open={@open} months={@months} days={@days} stats={@stats} />
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
            {(@debug.time && "#{div(@debug.time, 1000)} s") || "off"}
          </time>
        </li>
      </ul>
      <.button phx-click="update_sync_timer">Update Timer & Stats</.button>
      <.button disabled={!@debug.time} phx-click="cancel_sync_timer">Cancel Sync Timer</.button>
      <.button disabled={!!@debug.time} phx-click="start_sync_timer">Start Sync Timer</.button>
      <ul class="p-4 border rounded-lg bg-slate-200 border-slate-600">
        <li class="flex justify-between"><span>Organizations:</span>{@debug.stats.orgs}</li>
        <li class="flex justify-between"><span>Users:</span>{@debug.stats.users}</li>
        <li class="flex justify-between"><span>Events:</span>{@debug.stats.events}</li>
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
  def handle_event("toggle_open", %{"id" => id}, socket) do
    open = socket.assigns.open

    open =
      if MapSet.member?(open, id) do
        MapSet.delete(open, id)
      else
        MapSet.put(open, id)
      end

    {:noreply, assign(socket, open: open)}
  end

  @impl true
  def handle_info({:sync_finished, _}, socket) do
    months = Event.months!()
    days = Event.days!(%{group: true})
    open = socket.assigns.open
    open = if open == MapSet.new([]), do: initial_open(months), else: open

    socket = assign(socket, months: months, days: days, open: open)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:stats_finished, _}, socket) do
    socket = assign(socket, stats: Statistic.as_map!())

    {:noreply, socket}
  end

  defp initial_open(months), do: months |> Enum.map(&"month-#{&1}") |> MapSet.new()

  defp debug do
    %{
      enabled: Application.fetch_env!(:posa, :debug),
      time: Posa.Sync.get_time(),
      stats: %{
        orgs: Organization.count!(),
        users: User.count!(),
        events: Event.count!()
      }
    }
  end
end
