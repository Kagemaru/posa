defmodule Posa.Github.Data.User do
  @moduledoc "User model"

  use Ecto.Schema
  import Ecto.Changeset

  @required_fields ~w(login github_id avatar_url gravatar_id
                      url html_url followers_url following_url
                      gists_url starred_url subscriptions_url
                      organizations_url repos_url events_url
                      received_events_url type site_admin)a
  @optional_fields ~w()a

  @primary_key false
  embedded_schema do
    field :login, :string
    field :github_id, :integer
    field :avatar_url, :string
    field :gravatar_id, :string
    field :url, :string
    field :html_url, :string
    field :followers_url, :string
    field :following_url, :string
    field :gists_url, :string
    field :starred_url, :string
    field :subscriptions_url, :string
    field :organizations_url, :string
    field :repos_url, :string
    field :events_url, :string
    field :received_events_url, :string
    field :type, :string
    field :site_admin, :boolean, default: false
  end

  def changeset(schema \\ %__MODULE__{}, params) do
    schema
    |> cast(params, @required_fields, @optional_fields)
  end
end
