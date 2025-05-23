defmodule PosaWeb.MetricsLive do
  @moduledoc "Display the usage metrics for the user"
  use PosaWeb, :live_view

  def mount(_params, _session, socket) do
    metrics =
      if connected?(socket) do
        event_metrics()
      else
        nil
      end

    {:ok, assign(socket, metrics: metrics)}
  end

  def render(assigns) do
    ~H"""
    <%= if @metrics do %>
      <div class="grid grid-cols-3">
        <.metrics title="Commits today" metrics={@metrics.day.commits} />
        <.metrics title="Reviews today" metrics={@metrics.day.reviews} />
        <.metrics title="Issues today" metrics={@metrics.day.issues} />
        <.metrics title="Commits last week" metrics={@metrics.week.commits} />
        <.metrics title="Reviews last week" metrics={@metrics.week.reviews} />
        <.metrics title="Issues last week" metrics={@metrics.week.issues} />
        <.metrics title="Commits last month" metrics={@metrics.month.commits} />
        <.metrics title="Reviews last month" metrics={@metrics.month.reviews} />
        <.metrics title="Issues last month" metrics={@metrics.month.issues} />
      </div>
    <% else %>
      <div>Loading...</div>
    <% end %>
    """
  end

  attr :title, :string, required: true
  # attr :internal, :integer, required: true
  # attr :total, :integer, required: true
  attr :metrics, :map, required: true

  def metrics(assigns) do
    ~H"""
    <div class="p-2 m-2 bg-white border-4 border-blue-300 shadow-sm rounded-xl">
      <h2 class="text-lg font-bold">{@title}</h2>
      {@metrics.internal} from members<br />
      {@metrics.total - @metrics.internal} from external people<br />
      {@metrics.total} total<br />
    </div>
    """
  end

  defp event_metrics, do: Posa.Exports.event_metrics()
end
