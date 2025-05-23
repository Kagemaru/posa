defmodule Posa.Github do
  @moduledoc """
  Ash Domain to represend Github.
  """

  use Ash.Domain

  alias Posa.Github.Collaborator
  alias Posa.Github.Etag
  alias Posa.Github.Event
  alias Posa.Github.Member
  alias Posa.Github.Organization
  alias Posa.Github.Repository
  alias Posa.Github.Statistic
  alias Posa.Github.User

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
