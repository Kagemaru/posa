defmodule PosaWeb.PageLive do
  @moduledoc false

  use PosaWeb, :live_view

  alias Posa.Github.Data

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, events: Data.list_events())}
  end
end
