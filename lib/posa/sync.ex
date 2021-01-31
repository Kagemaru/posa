defmodule Posa.Sync do
  use GenServer

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def init(state) do
    spawn_link(&execute_sync/0)
    schedule_sync()
    {:ok, state}
  end

  def handle_info(:sync, state) do
    spawn_link(&execute_sync/0)
    schedule_sync()
    {:noreply, state}
  end

  defp sync_delay, do: Application.get_env(:posa, :sync_delay_ms)

  defp schedule_sync do
    Process.send_after(self(), :sync, sync_delay())
  end

  defp execute_sync, do: Posa.Github.Sync.run()
end
