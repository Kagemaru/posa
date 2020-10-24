defmodule PosaWeb.OSAListController do
  use PosaWeb, :controller

  alias Posa.Github.Data

  def index(conn, _params) do
    events = Data.list_events()
    render(conn, events: events)
  end

  def show(conn, %{"id" => id}) do
    event = Data.get_event(id)
    render(conn, event: event)
  end
end
