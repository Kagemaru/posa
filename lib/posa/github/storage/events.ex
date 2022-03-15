defmodule Posa.Github.Storage.Events do
  @moduledoc "Event storage"

  use Posa.Github.Storage.Base

  def add_event(user, id, value) do
    _update(&put_in_p(&1, [user, id], value))
  end

  def get_values_by([{key, val}]) do
    all_events() |> Enum.find(&match?(%{^key => ^val}, &1))
  end

  def all_events, do: merge_events(%{}, Map.values(get())) |> Map.values()
  def count, do: Enum.count(all_events())

  def output do
    all_events()
    |> sort(:created_at, &>=/2)
    |> top_50
  end

  defp top_50(list), do: list |> Enum.slice(0, 50)

  def merge_events(map, []), do: map

  def merge_events(map, [h | t]) do
    Map.merge(merge_events(map, t), h)
  end

  # def get_metrics(date_range) do
  #   metrics = get_internal_metrics(date_range)

  #   DeepMerge.deep_merge(
  #     %{
  #       members: %{commits: 0, issues: 0, reviews: 0, other: 0},
  #       external: %{commits: 0, issues: 0, reviews: 0, other: 0}
  #     },
  #     metrics
  #   )
  # end

  def get_metrics(date_range) do
    all_events()
    |> in_daterange(date_range)
    |> categorize_events()
    |> grouping
    |> then(
      &DeepMerge.deep_merge(
        %{
          members: %{commits: 0, issues: 0, reviews: 0, other: 0},
          external: %{commits: 0, issues: 0, reviews: 0, other: 0}
        },
        &1
      )
    )
  end

  defp in_daterange(events, date_range) do
    events |> Enum.filter(fn event -> NaiveDateTime.to_date(event.created_at) in date_range end)
  end

  defp categorize_events(events) do
    events
    |> Enum.reduce([], fn event, acc ->
      type =
        cond do
          event.type in types(:commits) -> :commits
          event.type in types(:issues) -> :issues
          event.type in types(:reviews) -> :reviews
          true -> :other
        end

      member = event.actor["login"] in members()

      [%{type: type, member: member} | acc]
    end)
  end

  defp grouping(metrics) do
    metrics
    |> Enum.group_by(&group_by_member/1)
    |> Enum.map(&map_groups/1)
    |> Enum.into(%{})
  end

  defp group_by_member(metric), do: if(metric.member, do: :members, else: :external)
  defp group_by_type(metric), do: metric.type

  defp map_groups({key, value}) do
    {
      key,
      Enum.group_by(value, &group_by_type/1)
      |> Enum.map(&map_counts/1)
      |> Enum.into(%{})
    }
  end

  defp map_counts({key, value}), do: {key, Enum.count(value)}

  def members do
    for(org <- Posa.Github.Storage.Organizations.get_all(), do: org.members)
    |> List.flatten()
  end

  defp types(:commits) do
    ~w[PushEvent]
  end

  defp types(:issues) do
    ~w[IssueCommentEvent IssuesEvent]
  end

  defp types(:reviews) do
    ~w[PullRequestReviewCommentEvent PullRequestReviewEvent]
  end
end
