defmodule Posa.GithubData do
  alias Posa.Store.{Organizations,Users,Events}
  alias Posa.GithubData.{Organization,User,Event}
  alias Ecto.Changeset

  def list_orgs,           do: orgs
  def list_users,          do: users
  def list_events,         do: events

  def get_org(id),         do: org(id: id)
  def get_user(id),        do: user(id: id)
  def get_event(id),       do: event(id: id)

  def get_org_by(query),   do: org(query)
  def get_user_by(query),  do: user(query)
  def get_event_by(query), do: event(query)

  def sort(list, key \\ :id, fun \\ &>=/2) do
    Users.sort(list, key, fun)
  end

  defp org(search),   do: Organizations.get_by(search)
  defp user(search),  do: Users.get_by(search)
  defp event(search), do: Events.get_by(search)

  defp orgs,   do: Organizations.get_all
  defp users,  do: Users.get_all
  defp events, do: Events.all_events

  defp org_cs(map),   do: Organization.changeset(%Organization{}, map)
  defp user_cs(map),  do: User.changeset(%User{}, map)
  defp event_cs(map), do: Event.changeset(%Event{}, map)
end
