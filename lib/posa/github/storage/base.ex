defmodule Posa.Github.Storage.Base do
  defmacro __using__(_) do
    quote do
      use Agent

      @default_value %{}

      def start_link(_), do: Agent.start_link(fn -> @default_value end, name: __MODULE__)
      def get, do: _get(& &1)
      def get(key), do: _get(&Map.get(&1, key))
      def get_all, do: _get(&Map.values(&1))
      def get_by([{key, val}]), do: get_all |> _find(key, val)
      def put(data), do: _update(fn _ -> data end)
      def put(key, data), do: _update(&Map.put(&1, key, data))
      def clear, do: _update(fn _ -> @default_value end)
      def sort(list, key, fun), do: list |> Enum.sort_by(& &1[key], fun)

      # Le plumbing
      defp _get(fun), do: Agent.get(__MODULE__, fun)
      defp _update(fun), do: Agent.update(__MODULE__, fun)
      defp _find(list, key, val), do: Enum.find(list, &match?(%{^key => ^val}, &1))
      defp _filter(list, key, val), do: Enum.filter(list, &match?(%{^key => ^val}, &1))

      defp put_in_p(map, list, value), do: create_path(map, list, []) |> put_in(list, value)
      defp create_path(map, [], _), do: map
      defp create_path(map, [h | t], []), do: create_path(map, t, [h])

      defp create_path(map, [h | t], memo) do
        case get_in(map, memo) do
          nil -> put_in(map, memo, %{})
          _ -> map
        end
        |> create_path(t, memo ++ [h])
      end
    end
  end
end
