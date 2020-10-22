defmodule PosaWeb.OSAListView do
  use PosaWeb, :view

  def make_it_json(input) do
    case Jason.encode(input) do
      {:ok, json} -> json
      _ -> "-"
    end
  end

  def group_by_month(list), do: Enum.group_by(list, &month_group/1)
  def group_by_day(list), do: Enum.group_by(list, &day_group/1)

  def month_tag(date), do: "#{month(date)}.#{year(date)}"
  def day_tag(date), do: "#{day(date)}.#{month(date)}.#{year(date)}"

  def month_class(date), do: "month-#{year(date)}-#{month(date)}"
  def day_class(date), do: "day-#{year(date)}-#{month(date)}-#{day(date)}"
  def time(date), do: "#{hour(date)}:#{minute(date)}"

  def url(event) do
    case event.payload do
      %{url: url} -> url
      _ -> "#"
    end
  end

  def author(event) do
    case event.payload do
      %{"commits" => [%{"author" => %{"name" => name}}]} ->
        name

      _ ->
        "N/A"
    end
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  def repo(event) do
    case event.repo do
      %{"name" => name} -> name
      _ -> "N/A"
    end
  end

  defp month_group(%{created_at: date}), do: Date.beginning_of_month(date)
  defp day_group(%{created_at: date}), do: NaiveDateTime.to_date(date)

  defp year(date), do: pad_date(date.year)
  defp month(date), do: pad_date(date.month)
  defp day(date), do: pad_date(date.day)
  defp hour(date), do: pad_date(date.hour)
  defp minute(date), do: pad_date(date.minute)

  defp pad_date(number) do
    number
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end
end
