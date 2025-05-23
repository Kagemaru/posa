defmodule Posa.Github do
  @moduledoc """
  Ash Domain to represend Github.
  """

  use Ash.Domain

  alias Posa.Github.{Organization, Member, User, Event, Etag, Repository, Collaborator, Statistic}

  resources do
    resource Organization
    resource Member
    resource User
    resource Event
    resource Etag
    resource Repository
    resource Collaborator

    resource Statistic do
      define :statistics_as_map, action: :as_map
    end
  end
end
