defmodule PosaWeb.OSAListView do
  use PosaWeb, :view
  use Timex

  import PosaWeb.DateTimeHelper

  def group_by_month(list) do
    list
    |> Enum.group_by(&month_group/1)
    |> Enum.sort(&group_sorter/2)
  end

  def group_by_day(list) do
    list
    |> Enum.group_by(&day_group/1)
    |> Enum.sort(&group_sorter/2)
    |> Enum.map(&event_sorter/1)
  end

  def month_tag(date), do: Timex.lformat!(date, "{Mfull} {YYYY}", "de")
  def day_tag(date), do: Timex.lformat!(date, "{WDfull} {0D}.{0M}.{YYYY}", "de")

  def month_class(date), do: "month-#{year(date)}-#{month(date)}"
  def day_class(date), do: "day-#{year(date)}-#{month(date)}-#{day(date)}"

  def render_event(event) do
    event
    |> render_custom
    |> render_default(event)
  end

  defp render_custom(event) do
    render_existing(
      PosaWeb.EventView,
      "_#{String.downcase(event.type)}.html",
      event: event
    )
  end

  defp render_default(nil, event) do
    render(
      PosaWeb.EventView,
      "_base.html",
      event: event
    )
  end

  defp render_default(output, _), do: output

  defp month_group(%{created_at: date}), do: Date.beginning_of_month(date)
  defp day_group(%{created_at: date}), do: NaiveDateTime.to_date(date)
  defp event_sorter({group, events}), do: {group, Enum.sort(events, &>=/2)}

  defp group_sorter({group, _}, {group2, _}) do
    case Date.compare(group, group2) do
      :gt -> true
      _ -> false
    end
  end
end
