defmodule PosaWeb.MonthGroupComponent do
  @moduledoc "This handles the display of the month grouping"
  use PosaWeb, :live_component

  def render(assigns) do
    ~H"""
    <details open={@open}>
      <summary class="flex flex-row items-center mb-8 rounded-full shadow-xl cursor-pointer w-min bg-pz-carolina-blue">
        <div class="flex flex-row items-center font-bold w-min px-3 py-2 rounded-full -ml-3.5 z-10 whitespace-nowrap h-10 border bg-white border-pz-carolina-blue text-pz-prussian-blue">
          <time
            class="before:w-4 before:h-4 before:mr-2 before:rounded-full before:inline-block before:relative before:top-0.5 before:border before:border-pz-prussian-blue before:bg-pz-carolina-blue"
            datetime={datetime(@month_group)}
          >
            <%= caption(@month_group) %>
          </time>
        </div>
        <div class="pl-2 pr-4 font-semibold whitespace-nowrap text-pz-prussian-blue">
          <%= count(@month_group) %>
        </div>
      </summary>
      <section class="z-10">
        <%= for {group, index} <- Enum.with_index(day_groups(@month_group)) do %>
          <.live_component
            module={PosaWeb.DayGroupComponent}
            id={"day-group-lv-#{:rand.uniform(999_999_999)}"}
            day_group={group}
            open={index == 0}
          />
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
