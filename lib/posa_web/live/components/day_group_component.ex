defmodule PosaWeb.DayGroupComponent do
  @moduledoc "This handles the display of a day entry on the timeline."
  use PosaWeb, :live_component

  def render(assigns) do
    ~L"""
    <details class="day-group" <%= if @open, do: "open" %>>
      <summary class="day-group__header">
        <time datetime="<%= datetime(@data) %>" class="day-group__left-container" >
          <%= caption(@data) %>
        </time>
        <div class="day-group__right-container">
          <%= count(@data) %>
        </div>
      </summary>
      <section class="day-group__body" >
        <div class="day-group__events">
          <%= for event <- get_events(@data) do %>
            <%= live_component @socket, PosaWeb.EventsComponent, data: event %>
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
