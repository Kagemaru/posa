defmodule PosaWeb.MetricsController do
  use PosaWeb, :controller

  alias Posa.Exports

  action_fallback PosaWeb.FallbackController

  def index(conn, _params) do
    render(conn, "index.json", metrics: metrics())
  end

  defp metrics do
    Exports.event_metrics()
  end
end
