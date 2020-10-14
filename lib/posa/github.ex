defmodule Posa.Github do
  use Supervisor

  alias Posa.Github.Storage.{Organizations,Users,Events,Etags}
  alias Posa.Sync

  @start_storage true
  @start_sync true

  def start_link(_opts) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

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
