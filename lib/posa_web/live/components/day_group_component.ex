defmodule PosaWeb.DayGroupComponent do
  @moduledoc "This handles the display of a day entry on the timeline."
  use PosaWeb, :live_component

  def render(assigns) do
    ~H"""
    <details open={@open}>
      <summary class="flex flex-row items-center cursor-pointer left-6 relative my-6
               before:z-10 before:w-3 before:h-3 before:rounded-full before:relative before:border before:inline-block before:-left-6 before:bg-white before:border-pz-prussian-blue
               after:w-7 after:h-1 after:-ml-0.after:5 after:rounded-full after:shadow-md after:border after:absolute after:-left-3 after:bg-white after:border-pz-prussian-blue">
        <time datetime={datetime(@day_group)} class="day-group__left-container">
          <%= caption(@day_group) %>
        </time>
        <div class="day-group__right-container">
          <%= count(@day_group) %>
        </div>
      </summary>
      <section class="day-group__body">
        <div class="day-group__events">
          <%= for event <- get_events(@day_group) do %>
            <.live_component
              module={PosaWeb.EventsComponent}
              id={"event-lv-#{event.github_id}"}
              event={event}
            />
          <% end %>
        </div>
      </section>
    </details>
    """
  end

  def caption(data) do
    data |> get_date |> Timex.lformat!("{WDfull} {0D}.{0M}.{YYYY}", "de")
  end

  def datetime(data) do
    data |> get_date |> Timex.format!("{YYYY}-{M}-{D}")
  end

  def count(data) do
    count = data |> get_events |> Enum.count()

    if count == 1, do: "#{count} Event", else: "#{count} Events"
  end

  defp get_date(data), do: elem(data, 0)
  defp get_events(data), do: elem(data, 1)
end
