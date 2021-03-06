defmodule PosaWeb.EventView do
  use PosaWeb, :view

  import PosaWeb.DateTimeHelper

  def time(date), do: "#{hour(date)}:#{minute(date)}"

  def make_it_json(input) do
    case Jason.encode(input) do
      {:ok, json} -> json
      _ -> "N/A"
    end
  end

  def make_it_markdown(nil), do: nil

  def make_it_markdown(input) do
    input
    |> Earmark.as_html!()
    |> raw
  end

  def url(event) do
    case event.payload do
      %{"commits" => [%{"url" => url}]} -> url
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
    with {:ok, url} <- Map.fetch(event.repo, "url"),
         {:ok, name} <- Map.fetch(event.repo, "name") do
      {
        name,
        remove_api(url)
      }
    else
      _ -> {"N/A", "#"}
    end
  end

  def remove_api(url) do
    url
    |> String.replace("api.github.com", "github.com")
    |> String.replace(["users/", "repos/"], "")
  end
end
