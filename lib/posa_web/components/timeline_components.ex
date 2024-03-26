defmodule PosaWeb.TimelineComponents do
  @moduledoc "Provides UI components for events."

  use PosaWeb, :html

  # Components {{{
  ## Timeline {{{

  attr :events, :list, doc: "List of events"
  slot :month, doc: "Month slot"

  def timeline(assigns) do
    assigns = assign(assigns, months: grouped_events(assigns.events))

    ~H"""
    <.timeline_bar />
    <%= for {days, index} <- Enum.with_index(@months) do %>
      <%= for month_slot <- @month do %>
        <%= render_slot(month_slot, %{index: index, days: days}) %>
      <% end %>
    <% end %>
    """
  end

  defp timeline_bar(assigns) do
    ~H"""
    <div
      id="timeline-bar"
      class={"fixed bottom-0 z-0 w-5 -m-1 bg-gradient-to-r from-pz-green-blue-crayola via-pz-maximum-blue-green to-pz-green-blue-crayola top-0" <> ""}
    >
    </div>
    """
  end

  ## /Timeline }}}
  ## MonthGroup {{{

  attr :open, :boolean, default: false, doc: "Open state of the month group"
  attr :days, :list, required: true, doc: "List of days"

  slot :day, doc: "Day slot"

  def month_group(assigns) do
    assigns =
      assign(assigns,
        counts: %{
          days: assigns.days |> Enum.count(),
          events: assigns.days |> Enum.map(&Enum.count(&1)) |> Enum.sum()
        },
        date:
          assigns.days
          |> List.first()
          |> List.first()
          |> Map.get(:created_at)
          |> Date.beginning_of_month()
      )

    ~H"""
    <details open={@open}>
      <.month_header date={@date} counts={@counts} />
      <section class="z-100">
        <%= for {events, index} <- Enum.with_index(@days) do %>
          <%= for day_slot <- @day do %>
            <%= render_slot(day_slot, %{index: index, events: events}) %>
          <% end %>
        <% end %>
      </section>
    </details>
    """
  end

  defp month_header(assigns) do
    ~H"""
    <summary class="relative flex flex-row items-center w-full h-10 mb-8 cursor-pointer -left-3.5">
      <.month_date_label date={@date} class="z-20 w-44 " />
      <.month_count_label
        label={ngettext("1 Day", "%{count} Days", @counts.days)}
        class="z-10 w-32 -ml-8 bg-pz-bright-navy-blue text-slate-100"
      />
      <.month_count_label
        label={ngettext("1 Event", "%{count} Events", @counts.events)}
        class="z-0 w-48 -ml-16 bg-pz-carolina-blue text-slate-100"
      />
    </summary>
    """
  end

  attr :date, :any, doc: "Date to display"
  attr :class, :string, default: "", doc: "CSS classes for the date"

  defp month_date_label(assigns) do
    ~H"""
    <div class={[
      "z-10 flex flex-row items-center justify-between h-full px-3 bg-white border rounded-full shadow-md border-pz-carolina-blue",
      @class
    ]}>
      <div class="relative w-4 h-4 mr-3 border rounded-full border-pz-prussian-blue bg-pz-carolina-blue">
      </div>

      <time
        datetime={Timex.format!(@date, "{YYYY}-{0M}")}
        class="flex flex-row justify-between w-full font-bold"
      >
        <span><%= Timex.lformat!(@date, "{Mfull}", "de") %></span>
        <span><%= Timex.format!(@date, "{YYYY}") %></span>
      </time>
    </div>
    """
  end

  attr :label, :string, default: "", doc: "Label for the count"
  attr :class, :string, default: "", doc: "CSS classes for the count"

  defp month_count_label(assigns) do
    ~H"""
    <div class={[
      "relative flex flex-row items-center justify-end h-full border border-white rounded-full shadow-md",
      @class
    ]}>
      <div class="pl-2 pr-4 font-semibold whitespace-nowrap ">
        <%= @label %>
      </div>
    </div>
    """
  end

  ## /MonthGroup }}}
  ## DayGroup {{{

  attr :open, :boolean, default: true, doc: "Open state of the month group"
  attr :events, :list, required: true, doc: "List of events"

  slot :event, doc: "Event slot"

  def day_group(assigns) do
    assigns =
      assign(
        assigns,
        date: assigns.events |> List.first() |> Map.get(:created_at) |> NaiveDateTime.to_date(),
        count: assigns.events |> Enum.count()
      )

    ~H"""
    <details open={@open}>
      <.day_header date={@date} count={@count} />
      <section class="relative mt-4 ml-8 animate-sweep">
        <div class="grid gap-4 grid-cols-auto_fit">
          <%= for event<- @events do %>
            <%= for event_slot <- @event do %>
              <%= render_slot(event_slot, event) %>
            <% end %>
          <% end %>
        </div>
      </section>
    </details>
    """
  end

  attr :date, :any, doc: "Date to display"
  attr :count, :integer, doc: "Count of events"

  defp day_header(assigns) do
    ~H"""
    <summary class="relative flex flex-row items-center w-full h-8 mb-4 cursor-pointer">
      <.day_date_label date={@date} class="z-20 w-56" />
      <.day_count_label
        label={ngettext("1 Event", "%{count} Events", @count)}
        class="z-10 -ml-8 w-36 bg-pz-carolina-blue text-slate-100"
      />
    </summary>
    """
  end

  attr :date, :any, doc: "Date to display"
  attr :class, :string, default: "", doc: "CSS classes for the date"

  defp day_date_label(assigns) do
    ~H"""
    <div class={[
      "z-10 flex flex-row items-center justify-between h-full",
      @class
    ]}>
      <div class="relative z-10 w-3 h-3 bg-white border rounded-full border-pz-prussian-blue"></div>
      <div class="relative z-20 w-3 h-1 bg-white border -left-[1px] border-pz-prussian-blue border-x-transparent">
      </div>
      <time
        datetime={Timex.format!(@date, "{YYYY}-{0M}-{0D}")}
        class="relative z-10 w-60 h-full font-semibold bg-white border rounded-full border-pz-carolina-blue text-pz-prussian-blue -left-[1px] flex flex-row items-center px-3 justify-between shadow-md"
      >
        <span><%= Timex.lformat!(@date, "{WDfull}", "de") %></span>
        <span><%= Timex.format!(@date, "{0D}.{0M}.{YYYY}") %></span>
      </time>
    </div>
    """
  end

  attr :label, :string, default: "", doc: "Label for the count"
  attr :class, :string, default: "", doc: "CSS classes for the count"

  defp day_count_label(assigns) do
    ~H"""
    <div class={[
      "font-semibold pr-4 h-full rounded-full shadow-md flex flex-row justify-end items-center border border-white",
      @class
    ]}>
      <%= @label %>
    </div>
    """
  end

  ## /DayGroup }}}
  # /Components }}}
  # Helper {{{

  def grouped_events(time_sorted_events) do
    time_sorted_events
    |> Enum.chunk_by(&day_grouper/1)
    |> Enum.chunk_by(&month_grouper/1)
  end

  defp day_grouper(%{created_at: date}), do: NaiveDateTime.to_date(date)
  defp month_grouper([%{created_at: date} | _]), do: Date.beginning_of_month(date)

  # /Helper}}}
end
