defmodule Posa.Github.API do
  alias Posa.Github.API.Client

  @type id :: String.t()
  @type item :: map()
  @type collection :: list(item())
  @type error :: String.t()
  @type url_path :: String.t()
  @type response :: Req.Response.t()

  @type single_return_ok :: {:ok, item()} | {:ok, :not_modified}
  @type collection_return_ok :: {:ok, collection()} | {:ok, []}
  @type return_error :: {:err, error()}

  @type single_return :: single_return_ok() | return_error()
  @type collection_return :: collection_return_ok() | return_error()

  @spec organization(id()) :: single_return()
  def organization(org_name), do: get!("/orgs/#{org_name}", :single)

  @spec user(id()) :: single_return()
  def user(id), do: get!("/users/#{id}", :single)

  @spec org_members(id()) :: collection_return()
  def org_members(org_name), do: get!("/orgs/#{org_name}/members?per_page=100", :collection)

  @spec events(id()) :: collection_return()
  def events(user), do: get!("/users/#{user}/events/public?per_page=100", :collection)

  @spec org_repositories(id()) :: collection_return()
  def org_repositories(org_name) do
    get!("/orgs/#{org_name}/repos?type=public&per_page=100", :collection)
  end

  @spec repo_collaborators(id(), id()) :: collection_return()
  def repo_collaborators(org_name, repo_name) do
    get!(
      "/repos/#{org_name}/#{repo_name}/collaborators?affiliation=outside&per_page=100",
      :collection
    )
  end

  @spec get!(url_path(), :single) :: single_return()
  @spec get!(url_path(), :collection) :: collection_return()
  defp get!(path, type), do: Req.get!(client(), url: path) |> handle_response(type)

  @spec handle_response(response(), :single) :: single_return()
  defp handle_response(response, :single) do
    case response.status do
      200 -> {:ok, response.body |> List.first()}
      304 -> {:ok, :not_modified}
      422 -> {:err, "Validation failed"}
      _ -> {:err, "Unexpected status code: #{response.status}"}
    end
  end

  @spec handle_response(response(), :collection) :: collection_return()
  defp handle_response(response, :collection) do
    case response.status do
      200 -> {:ok, response.body}
      304 -> {:ok, :not_modified}
      403 -> {:err, "Forbidden"}
      422 -> {:err, "Validation failed"}
      _ -> {:err, "Unexpected status code: #{response.status}"}
    end
  end

  defp client, do: Client.new()
end
