defmodule Posa.Sync do
  @moduledoc "Handles the recurring sync"

  alias Posa.Github.{Collaborator, Event, Member, Organization, Repository}
  alias Posa.Github.Statistic

  require Logger

  use GenServer

  # Client callbacks

  def start_link(_arg), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  def run_sync, do: GenServer.cast(__MODULE__, :run_sync)
  def set_timer(delay \\ nil), do: GenServer.call(__MODULE__, {:set_timer, delay || sync_delay()})
  def get_timer, do: GenServer.call(__MODULE__, :get_timer)
  def cancel_timer, do: GenServer.cast(__MODULE__, :cancel_timer)
  def get_time, do: GenServer.call(__MODULE__, :get_time)

  # Server callbacks

  def init(_) do
    if initial_sync(), do: execute_sync()

    delay = sync_delay()
    timer = schedule_sync(delay)

    {:ok, %{delay: delay, timer: timer}}
  end

  def handle_cast(:run_sync, state) do
    execute_sync()

    {:noreply, state}
  end

  def handle_cast(:cancel_timer, state) do
    Process.cancel_timer(state.timer)

    {:noreply, state}
  end

  def handle_call({:set_timer, delay}, _, state) do
    Process.cancel_timer(state.timer)
    timer = schedule_sync(delay)

    {:reply, timer, %{state | delay: delay, timer: timer}}
  end

  def handle_call(:get_time, _, state) do
    time = Process.read_timer(state.timer)

    {:reply, time, state}
  end

  def handle_call(:get_timer, _, state), do: {:reply, state.timer, state}

  def handle_info(:sync, state) do
    execute_sync()
    timer = schedule_sync(state.delay)

    {:noreply, %{state | timer: timer}}
  end

  defp execute_sync do
    {:ok, sync_task} =
      Task.start(fn ->
        start = System.monotonic_time()
        :telemetry.execute([:posa, :sync, :start], %{time: start})
        result = Enum.map([Organization, Member, Repository, Collaborator, Event], & &1.sync!())
        stop = System.monotonic_time()
        :telemetry.execute([:posa, :sync, :stop], %{time: stop, duration: stop - start})
        Logger.info("Sync completed")
        Phoenix.PubSub.broadcast(Posa.PubSub, "github:sync", {:sync_finished, result})

        start = System.monotonic_time()
        :telemetry.execute([:posa, :stats, :start], %{time: start})
        result = Statistic.calculate!()
        stop = System.monotonic_time()
        :telemetry.execute([:posa, :stats, :stop], %{time: stop, duration: stop - start})
        Logger.info("Stats collecting completed")
        Phoenix.PubSub.broadcast(Posa.PubSub, "github:stats", {:stats_finished, result})
      end)

    Process.register(sync_task, :sync_task)
  end

  defp schedule_sync(delay), do: Process.send_after(self(), :sync, delay)
  defp sync_delay, do: Application.get_env(:posa, :sync_delay_ms)
  defp initial_sync, do: Application.get_env(:posa, :initial_sync)
end
