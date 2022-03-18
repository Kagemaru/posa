defmodule PosaWeb.MonthGroupComponent do
  @moduledoc "This handles the display of the month grouping"
  use PosaWeb, :live_component

  def render(assigns) do
    ~L"""
    <details class="month-group" <%= if @open, do: "open" %>>
      <summary class="month-group__header">
        <div class="month-group__left-container">
          <time class="month-group__date" datetime="<%= datetime(@month_group) %>"><%= caption(@month_group) %></time>
        </div>
        <div class="month-group__right-container"><%= count(@month_group) %></div>
      </summary>
      <section class="month-group__body" >
        <%= for {group, index} <- Enum.with_index(day_groups(@month_group)) do %>
          <% open = index == 0 %>
          <%= live_component PosaWeb.DayGroupComponent, day_group: group, open: open %>
        <% end %>
      </section>
    </details>
    """
  end

  def caption(data) do
    data |> get_date |> Timex.lformat!("{Mfull} {YYYY}", "de")
  end

  def datetime(data) do
    data |> get_date |> Timex.format!("{YYYY}-{M}")
  end

  def count(data) do
    count = data |> get_events |> Enum.count()

    if count == 1, do: "#{count} Event", else: "#{count} Events"
  end

  def day_groups(data) do
    data
    |> get_events
    |> Enum.group_by(&day_group/1)
    |> Enum.sort(&group_sorter/2)
    |> Enum.map(&event_sorter/1)
  end

  defp day_group(%{created_at: date}), do: NaiveDateTime.to_date(date)

  defp event_sorter({group, events}), do: {group, Enum.sort(events, &>=/2)}

  defp group_sorter({group, _}, {group2, _}) do
    case Date.compare(group, group2) do
      :gt -> true
      _ -> false
    end
  end

  defp get_date(data), do: elem(data, 0)
  defp get_events(data), do: elem(data, 1)
end
