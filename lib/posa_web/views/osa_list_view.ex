defmodule PosaWeb.OSAListView do
  use PosaWeb, :view
  use Timex

  import PosaWeb.DateTimeHelper

  def group_by_month(list) do
    list
    |> Enum.group_by(&month_group/1)
    |> Enum.sort(&(elem(&1, 0) >= elem(&2, 0)))
  end

  def group_by_day(list) do
    list
    |> Enum.group_by(&day_group/1)
    |> Enum.sort(&(elem(&1, 0) >= elem(&2, 0)))
  end

  def month_tag(date), do: Timex.lformat!(date, "{Mfull} {YYYY}", "de")
  def day_tag(date), do: Timex.lformat!(date, "{WDfull} der {0D}.{0M}.{YYYY}", "de")

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
