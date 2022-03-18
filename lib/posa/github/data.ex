defmodule Posa.Github.Data do
  @moduledoc "Data interface for Github"

  alias Posa.Github.Storage.{Events, Organizations, Users}

  def list_orgs, do: orgs()
  def list_users, do: users()
  def list_events, do: events()

  def get_org(id), do: org(id: id)
  def get_user(id), do: user(id: id)
  def get_event(id), do: event(id: id)

  def get_org_by(params), do: org(params)
  def get_user_by(params), do: user(params)
  def get_event_by(params), do: event(params)

  def get_event_metrics(date_range), do: Events.get_metrics(date_range)

  def sort(list, key \\ :id, fun \\ &>=/2) do
    Users.sort(list, key, fun)
  end

  defp org(search), do: Organizations.get_by(search)
  defp user(search), do: Users.get_by(search)
  defp event(search), do: Events.get_values_by(search)

  defp orgs, do: Organizations.get_all()
  defp users, do: Users.get_all()
  defp events, do: Events.all_events()
end
