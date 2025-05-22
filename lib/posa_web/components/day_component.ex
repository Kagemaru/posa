defmodule PosaWeb.DayComponent do
  use PosaWeb, :html

  alias PosaWeb.EventsComponent, as: Events

  attr :open, :any, doc: "Open state of everything"
  attr :month, :any, required: true, doc: "Month to display"
  attr :day, :any, required: true, doc: "Day to display"
  attr :stats, :map, required: true, doc: "Statistics"

  def day_group(assigns) do
    id = "day-#{assigns.day}"
    open = MapSet.member?(assigns.open, id)
    count = assigns.stats["tags_day_#{assigns.day}"] || 0

    assigns = assign(assigns, id: id, count: count, open: open)

    ~H"""
    <.day_header id={@id} date={@day} count={@count} />
    <section :if={@open} id={@id} class="relative my-4 ml-8 animate-sweep">
      <.live_component module={Events} id={"events-#{@day}"} day={@day} />
    </section>
    """
  end

  attr :id, :string, doc: "ID of the day"
  attr :date, :any, doc: "Date to display"
  attr :count, :integer, doc: "Count of events"

  defp day_header(assigns) do
    ~H"""
    <div
      phx-click="toggle_open"
      phx-value-id={@id}
      class="relative flex flex-row items-center w-full h-8 mb-4 cursor-pointer"
    >
      <.day_date_label date={@date} class="z-20 w-64" />
      <.day_count_label
        label={ngettext("1 Event", "%{count} Events", @count)}
        class="z-10 -ml-8 w-44 bg-pz-carolina-blue text-slate-100"
      />
    </div>
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
end
