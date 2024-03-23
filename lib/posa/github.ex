defmodule Posa.Github do
  @moduledoc "Github Supervisor"

  use Supervisor

  alias Posa.Github.Storage.{Etags, Events, Organizations, Users}
  alias Posa.Sync

  @services %{
    storage: [Organizations, Users, Events, Etags],
    sync: [Sync]
  }

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, children(), name: __MODULE__)
  end

  def subscribe, do: Phoenix.PubSub.subscribe(Posa.PubSub, "updates")

  @impl true
  def init([]), do: :ignore

  def init(children) do
    Supervisor.init(children, strategy: :one_for_one, id: __MODULE__)
  end

  defp children do
    []
    |> add_services(:storage)
    |> add_services(:sync)
  end

  defp add_services(list, key), do: add_services(list, start?(key), @services[key])
  defp add_services(list, true, services), do: list ++ services
  defp add_services(list, _, _), do: list

  defp start?(key), do: Application.get_env(:posa, :services)[key] || false
end
