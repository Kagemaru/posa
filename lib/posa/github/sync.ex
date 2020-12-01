defmodule Posa.Github.Sync do
  alias Posa.Github.API
  alias Posa.Github.Storage.{Organizations, Users, Events}
  alias Posa.Github.Data.{Organization, User, Event}

  @orgs Application.fetch_env!(:posa, :organizations)

  def run do
    API.start()
    fetch_organizations()
    fetch_org_members()
    fetch_users()
    fetch_events()
  end

  def fetch_organizations do
    for name <- @orgs, do: fetch_resource(:organization, name)
  end

  def fetch_org_members do
    for org <- Organizations.get_all(), do: fetch_resource(:member, org[:login])
  end

  def fetch_users do
    for org <- Organizations.get_all() do
      for login <- org[:members] do
        fetch_resource(:user, login)
      end
    end
  end

  def fetch_events do
    for user <- Users.get_all(), do: fetch_resource(:event, user.login)
  end

  def fetch_resource(:member, name) do
    case get(:member, name) do
      nil -> nil
      response -> put(:member, response, name)
    end

    name
  end

  def fetch_resource(:event, name) do
    case get(:event, name) do
      nil ->
        nil

      events ->
        {name,
         for event <- events do
           with %{changes: res, valid?: true} <- changeset(:event, event),
                id <- res.github_id,
                :ok <- put(:event, res, name),
                do: id
         end}
    end
  end

  def fetch_resource(type, name) do
    case get(type, name) do
      nil ->
        nil

      response ->
        with %{changes: res, valid?: true} <- changeset(type, response),
             id <- res.login,
             :ok <- put(type, res),
             do: id
    end
  end

  defp changeset(:organization, response), do: Organization.changeset(%Organization{}, response)
  defp changeset(:user, response), do: User.changeset(%User{}, response)
  defp changeset(:event, response), do: Event.changeset(%Event{}, response)
  defp get(type, name), do: API.get_resource(type, name)
  defp put(type, resource, name \\ nil)
  defp put(:organization, resource, _), do: Organizations.put(resource.login, resource)
  defp put(:user, resource, _), do: Users.put(resource.login, resource)
  defp put(:event, resource, name), do: Events.add_event(name, resource.github_id, resource)

  defp put(:member, resource, name) do
    org_with_members =
      name
      |> Organizations.get()
      |> Map.put(:members, resource)

    Organizations.put(name, org_with_members)
  end
end
