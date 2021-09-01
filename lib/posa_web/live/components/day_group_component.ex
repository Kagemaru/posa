defmodule PosaWeb.DayGroupComponent do
  @moduledoc "This handles the display of a day entry on the timeline."
  use PosaWeb, :live_component

  def render(assigns) do
    ~L"""
    <style>
      <!--
      details.day-group[open] summary ~ * {
        animation: sweep .5s ease-in-out;
      }

      @keyframes sweep {
        0%    {opacity: 0; transform: translateX(-10px)}
        100%  {opacity: 1; transform: translateX(0)}
      }
      -->
    </style>
    <details class="mb-2 day-group" <%= if @open, do: "open" %>>
      <summary class="flex flex-row items-center cursor-pointer">
        <div class="z-10 w-3 h-3 ml-1 bg-gray-300 border border-gray-600 rounded-full">&nbsp;</div>
        <div class="w-7 h-1 -ml-0.5 rounded-full bg-gray-300 border border-gray-600 shadow-md">&nbsp;</div>
        <time datetime="<%= datetime(@data) %>" class="z-20 px-4 py-1 font-semibold text-white bg-blue-300 rounded-full shadow-md" >
          <%= caption(@data) %>
        </time>
        <div class="z-10 px-6 py-1 pl-12 -ml-10 font-semibold text-white bg-gray-700 rounded-full shadow-md">
          <%= count(@data) %>
        </div>
      </summary>
      <section class="mt-4 ml-5 w-30" >
        <div class="grid grid-flow-row gap-4 lg:grid-cols-2">
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
