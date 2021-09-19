defmodule Posa.Github do
  @moduledoc "Github Supervisor"

  use Supervisor

  alias Posa.Github.Storage.{Etags, Events, Organizations, Users}
  alias Posa.Sync

  # Extract to config
  @dialyzer {:nowarn_function, init: 1, add_storage: 1, add_sync: 1}
  @start_storage true
  @start_sync true

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def subscribe, do: Phoenix.PubSub.subscribe(Posa.PubSub, "updates")

  @impl true
  def init(:ok) do
    children =
      []
      |> add_storage()
      |> add_sync()

    Supervisor.init(children, strategy: :one_for_one, id: __MODULE__)
  end

  defp add_storage(list) do
    case @start_storage do
      true -> list ++ [Organizations, Users, Events, Etags]
      _ -> list
    end
  end

  defp add_sync(list) do
    case @start_sync do
      true -> list ++ [Sync]
      _ -> list
    end
  end
end
