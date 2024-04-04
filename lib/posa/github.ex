defmodule Posa.Github do
  use Ash.Domain

  resources do
    resource Posa.Github.Organization
    resource Posa.Github.User
    resource Posa.Github.Event
    resource Posa.Github.Etag

    resource Posa.Github.Statistic do
      define :statistics_as_map, action: :as_map
    end
  end
end
