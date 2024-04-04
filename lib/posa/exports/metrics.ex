defmodule Posa.Exports.Metrics do
  @moduledoc "This handles the generating of the metrics for export"

  # @type user_type :: :internal | :external
  # @type event_type :: :commits | :issues | :reviews | :other
  # @type range :: :day | :week | :month | :total
  # @type date :: DateTime.t()
  # @type day_count :: integer()
  # @type week_count :: integer()
  # @type month_count :: integer()
  # @type total_count :: integer()
  # @type event_source :: {
  #         user_type(),
  #         event_type(),
  #         day_count(),
  #         week_count(),
  #         month_count(),
  #         total_count()
  #       }
  # @type event_sources :: [event_source()]
  # @type stats :: %{
  #         user: user_type(),
  #         event: event_type(),
  #         counts: %{
  #           day: day_count(),
  #           week: week_count(),
  #           month: month_count(),
  #           total: total_count()
  #         }
  #       }

  def all_metrics do
    Posa.Github.Event.read!() |> Enum.map(&count/1)

    Process.get(:counts)
  end

  def count(event) do
    user_type = internal?(event.actor.login)
    event_type = event_type(event.type)
    month = month_tag(event.created_at)
    day = day_tag(event.created_at)
    count_day? = date_in_range?(event.created_at, :day)
    count_week? = date_in_range?(event.created_at, :week)
    count_month? = date_in_range?(event.created_at, :month)

    count_event(:month, event_type, user_type, count_month?)
    count_event(:week, event_type, user_type, count_week?)
    count_event(:day, event_type, user_type, count_day?)
    count_event(:total, event_type, user_type, true)

    increase({:tags, :month, month}, true)
    increase({:tags, :day, day}, true)
  end

  def count_event(topic, event_type, user_type, count?) do
    increase({topic, :total, :total}, count?)
    increase({topic, :total, user_type}, count?)
    increase({topic, event_type, :total}, count?)
    increase({topic, event_type, user_type}, count?)
  end

  def increase(keys, true) do
    {key1, key2, key3} = keys

    counts =
      (Process.get(:counts) || %{})
      |> update_in([Access.key(key1, %{}), Access.key(key2, %{}), Access.key(key3, 0)], &(&1 + 1))

    Process.put(:counts, counts)
  end

  def increase(_, _), do: nil

  def internal?(login) do
    if login in logins(), do: :internal, else: :external
  end

  def date_in_range?(date, :day), do: Date.diff(date, now()) >= -1
  def date_in_range?(date, :week), do: Date.diff(date, now()) >= -7
  def date_in_range?(date, :month), do: Date.diff(date, now()) >= -30
  def date_in_range?(_, :total), do: true

  def now, do: DateTime.now!("Europe/Zurich")

  def event_type(type) do
    case type do
      type when type in ~w[PushEvent] -> :commits
      type when type in ~w[IssueCommentEvent IssuesEvent] -> :issues
      type when type in ~w[PullRequestReviewCommentEvent PullRequestReviewEvent] -> :reviews
      _ -> :other
    end
  end

  defp month_tag(date), do: Posa.Utils.month_tag(date) |> Map.get(:date)
  defp day_tag(date), do: Posa.Utils.day_tag(date) |> Map.get(:date)

  defp logins, do: Posa.Github.Member.logins!()
end
