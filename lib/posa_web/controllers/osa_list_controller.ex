defmodule PosaWeb.OSAListController do
  use PosaWeb, :controller

  alias Posa.GithubData

  def index(conn, _params) do
    events = GithubData.list_events
    render(conn, events: events)
  end

  def show(conn, %{"id" => id}) do
    event = GithubData.get_event(id)
    render(conn, event: event)
  end
end
