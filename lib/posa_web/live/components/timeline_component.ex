defmodule PosaWeb.TimelineComponent do
  use PosaWeb, :live_component

  def render(assigns) do
    ~L"""
    <div id="timeline" class="">
      <div class="absolute top-0 bottom-0 z-0 w-3 bg-gray-400 border border-gray-500 left-7"></div>
    </div>
    <div id="events" class="">
      <%= for group <- Enum.with_index(month_groups(@events)) do %>
        <%= live_component @socket, PosaWeb.MonthGroupComponent, data: elem(group, 0), open: elem(group, 1) == 0 %>
      <% end %>
    </div>
    """
  end

  def month_groups(events) do
    events
    |> Enum.group_by(&month_group/1)
    |> Enum.sort(&group_sorter/2)
  end

  defp month_group(%{created_at: date}), do: Date.beginning_of_month(date)

  defp group_sorter({group, _}, {group2, _}) do
    case Date.compare(group, group2) do
      :gt -> true
      _ -> false
    end
  end
end
