defmodule PosaWeb.TimelineComponent do
  @moduledoc "This Component is for displaying the timeline view."

  use PosaWeb, :live_component

  def render(assigns) do
    ~L"""
    <div id="timeline"></div>
    <div id="events">
      <%= for {group, index} <- Enum.with_index(month_groups(@events)) do %>
        <% open = index == 0 %>
        <%= live_component PosaWeb.MonthGroupComponent, month_group: group, open: open %>
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
