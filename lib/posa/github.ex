defmodule Posa.Github do
  @moduledoc "Github Supervisor"

  use Supervisor

  alias Posa.Github.Storage.{Etags, Events, Organizations, Users}
  alias Posa.Sync

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def subscribe, do: Phoenix.PubSub.subscribe(Posa.PubSub, "updates")

  @impl true
  def init([]), do: :ignore

  def init(_) do
    children =
      List.flatten([
        storage_services(),
        sync_services()
      ])

    Supervisor.init(children, strategy: :one_for_one, id: __MODULE__)
  end

  def storage_services do
    if start?(:storage), do: [Organizations, Users, Events, Etags], else: []
  end

  def sync_services do
    if start?(:sync), do: [Sync], else: []
  end

  defp start?(key), do: Application.get_env(:posa, :services)[key] || false
end
