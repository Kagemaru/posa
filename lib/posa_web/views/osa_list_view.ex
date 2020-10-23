defmodule PosaWeb.OSAListView do
  use PosaWeb, :view

  import PosaWeb.DateTimeHelper

  def group_by_month(list), do: Enum.group_by(list, &month_group/1)
  def group_by_day(list), do: Enum.group_by(list, &day_group/1)

  def month_tag(date), do: "#{month(date)}.#{year(date)}"
  def day_tag(date), do: "#{day(date)}.#{month(date)}.#{year(date)}"

  def month_class(date), do: "month-#{year(date)}-#{month(date)}"
  def day_class(date), do: "day-#{year(date)}-#{month(date)}-#{day(date)}"

  def render_event(event) do
    render(
      PosaWeb.EventView,
      "_#{String.downcase(event.type)}.html",
      event: event
    )
  end

  defp month_group(%{created_at: date}), do: Date.beginning_of_month(date)
  defp day_group(%{created_at: date}), do: NaiveDateTime.to_date(date)
end
