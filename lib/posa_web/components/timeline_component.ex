defmodule PosaWeb.TimelineComponent do
  @moduledoc """
  Display components for the timeline view.
  """

  alias PosaWeb.MonthComponent
  use PosaWeb, :html

  import MonthComponent, only: [month_group: 1]

  attr :open, :any, doc: "Open states of everything"
  attr :months, :list, doc: "List of months"
  attr :days, :map, doc: "List of days, grouped by month"
  attr :stats, :map, doc: "Statistics"

  def timeline(assigns) do
    ~H"""
    <.timeline_bar />
    <div id="months">
      <.month_group
        :for={month <- @months}
        month={month}
        open={@open}
        days={@days[month]}
        stats={@stats}
      />
    </div>
    """
  end

  def timeline_bar(assigns) do
    ~H"""
    <div
      id="timeline-bar"
      class="fixed top-0 bottom-0 z-0 w-5 -m-1 bg-gradient-to-r from-pz-green-blue-crayola via-pz-maximum-blue-green to-pz-green-blue-crayola"
    >
    </div>
    """
  end
end
