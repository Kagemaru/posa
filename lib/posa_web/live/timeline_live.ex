defmodule PosaWeb.TimelineLive do
  @moduledoc false

  use PosaWeb, :live_view

  alias Posa.Github.Data

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, events: list_events())}
  end

  def list_events do
    Data.list_events() |> deep_atomize_keys
  end

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
end
