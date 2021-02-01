defmodule Posa.Github.Storage.Events do
  @moduledoc "Event storage"

  use Posa.Github.Storage.Base

  def add_event(user, id, value) do
    _update(&put_in_p(&1, [user, id], value))
  end

  def all_events, do: merge_events(%{}, Map.values(get())) |> Map.values()
  def count, do: Enum.count(all_events())

  def output do
    all_events()
    |> sort(:created_at, &>=/2)
    |> top_50
  end

  # defp sort_by(list, key), do: list |> Enum.sort_by(& &1[key], &>=/2)
  defp top_50(list), do: list |> Enum.slice(0, 50)

  def merge_events(map, []), do: map

  def merge_events(map, [h | t]) do
    Map.merge(merge_events(map, t), h)
  end
end
