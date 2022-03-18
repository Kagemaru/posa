defmodule PosaWeb.MetricsView do
  use PosaWeb, :view

  def render("index.json", %{metrics: metrics}), do: metrics
end
