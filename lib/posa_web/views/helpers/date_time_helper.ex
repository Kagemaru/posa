defmodule PosaWeb.DateTimeHelper do
  def year(date), do: pad_date(date.year)
  def month(date), do: pad_date(date.month)
  def day(date), do: pad_date(date.day)
  def hour(date), do: pad_date(date.hour)
  def minute(date), do: pad_date(date.minute)

  def pad_date(number) do
    number
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end
end
