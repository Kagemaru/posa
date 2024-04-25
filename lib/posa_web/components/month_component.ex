defmodule PosaWeb.MonthComponent do
  use PosaWeb, :html

  import PosaWeb.DayComponent, only: [day_group: 1]

  attr :open, :any, doc: "Open states of everything"
  attr :month, :any, required: true, doc: "Month to display"
  attr :days, :list, required: true, doc: "List of days"
  attr :stats, :map, required: true, doc: "Statistics"

  def month_group(assigns) do
    id = "month-#{assigns.month}"
    show = MapSet.member?(assigns.open, id)

    counts = %{
      days: (assigns.days || []) |> Enum.count(),
      events: assigns.stats["tags_month_#{assigns.month}"] || 0
    }

    assigns = assign(assigns, id: id, show: show, counts: counts)

    ~H"""
    <.month_header id={@id} date={@month} counts={@counts} />
    <section :if={@show} id={"#{@id}-days"} class="z-100">
      <.day_group :for={day <- @days} day={day} month={@month} open={@open} stats={@stats} />
    </section>
    """
  end

  attr :id, :string, doc: "ID of the month"
  attr :date, :any, doc: "Date to display"
  attr :counts, :map, doc: "Counts of days and events"

  def month_header(assigns) do
    ~H"""
    <div
      phx-click="toggle_open"
      phx-value-id={@id}
      class="relative flex flex-row items-center w-full h-10 mb-8 cursor-pointer -left-3.5"
    >
      <.month_date_label date={@date} class="z-20 w-44" />
      <.month_count_label
        label={ngettext("1 Day", "%{count} Days", @counts.days)}
        class="z-10 w-32 -ml-8 bg-pz-bright-navy-blue text-slate-100"
      />
      <.month_count_label
        label={ngettext("1 Event", "%{count} Events", @counts.events)}
        class="z-0 w-48 -ml-16 bg-pz-carolina-blue text-slate-100"
      />
    </div>
    """
  end

  attr :date, :any, doc: "Date to display"
  attr :class, :string, default: "", doc: "CSS classes for the date"

  def month_date_label(assigns) do
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

  def month_count_label(assigns) do
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
end
