defmodule Posa.Github.API do
  use HTTPoison.Base
  alias Posa.Github.Storage.{Organizations, Users, Events, Etags}

  @token Application.fetch_env!(:posa, :github_token)

  def get_or_retry(url, count \\ 1) do
    try do
      get!(url)
    rescue
      e in HTTPoison.Error ->
        case count do
          x when x in 1..3 -> 1_000
          x when x in 4..6 -> 10_000
          x when x in 7..9 -> 100_000
          _ -> raise e
        end
        |> :timer.sleep()

        get_or_retry(url, count + 1)
    end
  end

  def get_resource(type, id) do
    with store <- store(type),
         url <- url(type, id),
         etag_id <- etag_id(type, id),
         :ok <- set_etag(store, etag_id),
         response <- get_or_retry(url) do
      case response.body do
        nil ->
          nil

        _ ->
          response
          |> save_etag(store, etag_id)
          |> Map.get(:body)
          |> set_github_id
          |> extract_member_logins(type)
      end
    end
  end

  # API Wrapper stuff
  def process_url(url) do
    "https://api.github.com/" <> String.replace_leading(url, "/", "")
  end

  def process_request_headers(headers) do
    headers
    |> Enum.concat([{"User-Agent", "posa"}])
    |> Enum.concat([{"Authorization", "token #{@token}"}])
    |> Enum.concat([{"If-None-Match", Etags.get(:current) || ""}])
  end

  def process_request_options(options) do
    options
    |> Keyword.put(:recv_timeout, 10000)
    |> Keyword.put(:ssl, [{:ciphers, :ssl.cipher_suites(:all)}])
  end

  def process_response_body(body) do
    case body do
      "" -> nil
      x -> Poison.decode!(x)
    end
  end

  defp store(:organization), do: Organizations
  defp store(:member), do: Organizations
  defp store(:user), do: Users
  defp store(:event), do: Events

  defp url(:organization, id), do: "orgs/#{id}"
  defp url(:member, id), do: "orgs/#{id}/public_members?per_page=100"
  defp url(:user, id), do: "users/#{id}"
  defp url(:event, id), do: "users/#{id}/events/public?per_page=50"

  defp etag_id(:member, id), do: id <> "_members"
  defp etag_id(_type, id), do: id

  defp extract_member_logins(list, :member), do: Enum.map(list, & &1["login"])
  defp extract_member_logins(map, _), do: map

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
