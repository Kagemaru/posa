defmodule Posa.Github.API do
  @moduledoc "Github API Interface"

  use HTTPoison.Base
  alias Posa.Github.Storage.{Etags, Events, Organizations, Users}

  def get_or_retry(url, count \\ 1) do
    get!(url)
  rescue
    e in HTTPoison.Error ->
      case count do
        x when x in 1..3 -> 1_000
        x when x in 4..6 -> 10_000
        x when x in 7..9 -> 100_000
        _ -> reraise(e, __STACKTRACE__)
      end
      |> :timer.sleep()

      get_or_retry(url, count + 1)
  end

  def get_resource(type, id) do
    with store <- store(type),
         url <- url(type, id),
         etag_id <- etag_id(type, id),
         :ok <- set_etag(store, etag_id),
         response <- get_or_retry(url),
         code when code != 403 <- response.status_code do
      case response.body do
        nil ->
          nil

        _ ->
          response
          |> save_etag(store, etag_id)
          |> paginate
          |> set_github_id
          |> extract(type)
      end
    else
      _ -> nil
    end
  end

  def paginate(response) do
    output =
      case next_link(response.headers) do
        nil -> response.body
        link -> response.body ++ (get_or_retry(link) |> paginate)
      end

    output
  end

  defp next_link(headers) do
    link_header =
      headers
      |> Enum.into(%{})
      |> Map.get("Link")

    links =
      case link_header do
        nil ->
          []

        _ ->
          link_header
          |> String.split(", ")
          |> Enum.filter(&String.contains?(&1, "rel=\"next\""))
      end

    case links do
      [] ->
        nil

      [link] ->
        link
        |> String.split("; ")
        |> List.first()
        |> String.slice(24..-2//1)
    end
  end

  # API Wrapper stuff
  def process_url(url) do
    "https://api.github.com/" <> String.replace_leading(url, "/", "")
  end

  def process_request_headers(headers) do
    headers
    |> Enum.concat([{"User-Agent", "posa"}])
    |> Enum.concat([{"Authorization", "token #{github_token()}"}])
    |> Enum.concat([{"If-None-Match", Etags.get(:current) || ""}])
  end

  def process_request_options(options) do
    options
    |> Keyword.put(:recv_timeout, 10_000)
    |> Keyword.put(:ssl, [{:ciphers, :ssl.cipher_suites(:all, :"tlsv1.3")}])
  end

  def process_response_body(body) do
    case body do
      "" -> nil
      x -> Poison.decode!(x)
    end
  end

  defp github_token, do: Application.get_env(:posa, :github_token)

  defp store(:organization), do: Organizations
  defp store(:member), do: Organizations
  defp store(:repos), do: Organizations
  defp store(:user), do: Users
  defp store(:collaborators), do: Users
  defp store(:event), do: Events

  defp url(:organization, id), do: "orgs/#{id}"
  defp url(:member, id), do: "orgs/#{id}/public_members?per_page=100"
  defp url(:repos, id), do: "orgs/#{id}/repos?type=public&per_page=100"
  defp url(:user, id), do: "users/#{id}"
  defp url(:collaborators, id), do: "repos/#{id}/collaborators?affiliation=outside&per_page=100"
  defp url(:event, id), do: "users/#{id}/events/public?per_page=50"

  defp etag_id(:member, id), do: id <> "_members"
  defp etag_id(:repos, id), do: id <> "_repos"
  defp etag_id(:collaborators, id), do: id <> "_collaborators"
  defp etag_id(_type, id), do: id

  defp extract(list, type) when type in [:member, :collaborators],
    do: Enum.map(list, & &1["login"]) |> Enum.sort()

  defp extract(list, :repos), do: Enum.map(list, & &1["name"]) |> Enum.sort()
  defp extract(list, _), do: list

  defp set_github_id(map, key \\ "id") do
    case map do
      %{} -> put_in(map, ["github_id"], map[key])
      _ -> Enum.map(map, &Map.put(&1, "github_id", &1[key]))
    end
  end

  def set_etag(domain, key) do
    Etags.put(:current, Etags.get_etag(domain, key))
    :ok
  end

  defp save_etag(response, domain, key) do
    with etag <- response |> extract_etag,
         do: Etags.put_etag(domain, key, etag)

    response
  end

  defp extract_etag(response) do
    response.headers
    |> List.keyfind("ETag", 0)
    |> elem(1)
  end
end
