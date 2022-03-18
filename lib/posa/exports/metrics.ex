defmodule Posa.Exports.Metrics do
  @moduledoc "This handles the generating of the metrics for export"
  alias Posa.Github.Data

  def all_metrics do
    get_metrics()
    |> sum_range(:day)
    |> sum_range(:week)
    |> sum_range(:month)
  end

  def get_metrics do
    %{
      day: date_range(:day) |> get_metrics(),
      week: date_range(:week) |> get_metrics(),
      month: date_range(:month) |> get_metrics()
    }
  end

  def get_metrics(date_range), do: Data.get_event_metrics(date_range)

  defp date_range(:day), do: Date.add(Date.utc_today(), -1) |> date_range()
  defp date_range(:week), do: Date.add(Date.utc_today(), -7) |> date_range()
  defp date_range(:month), do: Date.add(Date.utc_today(), -30) |> date_range()
  defp date_range(start), do: Date.range(start, Date.utc_today())

  defp sum_range(metrics, key) do
    %{^key => %{members: members, external: external}} = metrics
    sum = sum(members, external)

    put_in(metrics, [key, :all], sum)
  end

  defp sum(members, external) do
    %{
      commits: members.commits + external.commits,
      issues: members.issues + external.issues,
      reviews: members.reviews + external.reviews
    }
  end
end
