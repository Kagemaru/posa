defmodule PosaWeb.MetricsLive do
  use PosaWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, metrics: event_metrics())}
  end

  def render(assigns) do
    ~H"""
    <div class="grid grid-cols-3">
      <div class="p-2 m-2 bg-white border border-4 border-blue-300 shadow-sm rounded-xl">
        <h2 class="text-lg font-bold">Commits today</h2>
        <%= @metrics.day.members.commits %> from members<br />
        <%= @metrics.day.external.commits %> from external people<br />
        <%= @metrics.day.all.commits %> total<br />
      </div>
      <div class="p-2 m-2 bg-white border border-4 border-blue-300 shadow-sm rounded-xl">
        <h2 class="text-lg font-bold">Reviews today</h2>
        <%= @metrics.day.members.reviews %> from members<br />
        <%= @metrics.day.external.reviews %> from external people<br />
        <%= @metrics.day.all.reviews %> total<br />
      </div>
      <div class="p-2 m-2 bg-white border border-4 border-blue-300 shadow-sm rounded-xl">
        <h2 class="text-lg font-bold">Issues today</h2>
        <%= @metrics.day.members.issues %> from members<br />
        <%= @metrics.day.external.issues %> from external people<br />
        <%= @metrics.day.all.issues %> total<br />
      </div>
      <div class="p-2 m-2 bg-white border border-4 border-blue-300 shadow-sm rounded-xl">
        <h2 class="text-lg font-bold">Commits last week</h2>
        <%= @metrics.week.members.commits %> from members<br />
        <%= @metrics.week.external.commits %> from external people<br />
        <%= @metrics.week.all.commits %> total<br />
      </div>
      <div class="p-2 m-2 bg-white border border-4 border-blue-300 shadow-sm rounded-xl">
        <h2 class="text-lg font-bold">Reviews last week</h2>
        <%= @metrics.week.members.reviews %> from members<br />
        <%= @metrics.week.external.reviews %> from external people<br />
        <%= @metrics.week.all.reviews %> total<br />
      </div>
      <div class="p-2 m-2 bg-white border border-4 border-blue-300 shadow-sm rounded-xl">
        <h2 class="text-lg font-bold">Issues last week</h2>
        <%= @metrics.week.members.issues %> from members<br />
        <%= @metrics.week.external.issues %> from external people<br />
        <%= @metrics.week.all.issues %> total<br />
      </div>
      <div class="p-2 m-2 bg-white border border-4 border-blue-300 shadow-sm rounded-xl">
        <h2 class="text-lg font-bold">Commits last month</h2>
        <%= @metrics.month.members.commits %> from members<br />
        <%= @metrics.month.external.commits %> from external people<br />
        <%= @metrics.month.all.commits %> total<br />
      </div>
      <div class="p-2 m-2 bg-white border border-4 border-blue-300 shadow-sm rounded-xl">
        <h2 class="text-lg font-bold">Reviews last month</h2>
        <%= @metrics.month.members.reviews %> from members<br />
        <%= @metrics.month.external.reviews %> from external people<br />
        <%= @metrics.month.all.reviews %> total<br />
      </div>
      <div class="p-2 m-2 bg-white border border-4 border-blue-300 shadow-sm rounded-xl">
        <h2 class="text-lg font-bold">Issues last month</h2>
        <%= @metrics.month.members.issues %> from members<br />
        <%= @metrics.month.external.issues %> from external people<br />
        <%= @metrics.month.all.issues %> total<br />
      </div>
    </div>
    """
  end

  defp event_metrics, do: Posa.Exports.event_metrics()
end
