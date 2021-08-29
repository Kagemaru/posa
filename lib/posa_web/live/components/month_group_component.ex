defmodule PosaWeb.MonthGroupComponent do
  use PosaWeb, :live_component

  def render(assigns) do
    ~L"""
    <details class="flex flex-col mb-8 month-group" <%= if @open, do: "open" %>>
      <summary class="flex flex-row items-center mb-8 bg-gray-700 rounded-full shadow-xl w-min">
        <div class="flex flex-row items-center bg-gray-300 text-gray-800 font-bold w-min px-3 py-2 rounded-full -ml-3.5 z-10 whitespace-nowrap h-10">
          <div class="w-4 h-4 mr-2 bg-gray-200 border-gray-200 rounded-full">&nbsp;</div>
          <div>
            <time datetime="<%= datetime(@data) %>"><%= caption(@data) %></time>
          </div>
        </div>
        <div class="pl-2 pr-4 font-semibold text-gray-200 whitespace-nowrap"><%= count(@data) %></div>
      </summary>
      <section class="z-10" >
        <%= for group <- Enum.with_index(day_groups(@data)) do %>
          <%= live_component @socket, PosaWeb.DayGroupComponent, data: elem(group, 0), open: elem(group, 1) == 0 %>
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
