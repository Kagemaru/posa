defmodule Posa.Github.User do
  use Ash.Resource, domain: Posa.Github, data_layer: Ash.DataLayer.Ets

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    integer_primary_key :id

    attribute :login, :string
    attribute :node_id, :string
    attribute :avatar_url, :string
    attribute :gravatar_id, :string
    attribute :url, :string
    attribute :html_url, :string
    attribute :followers_url, :string
    attribute :following_url, :string
    attribute :gists_url, :string
    attribute :starred_url, :string
    attribute :subscriptions_url, :string
    attribute :organizations_url, :string
    attribute :repos_url, :string
    attribute :events_url, :string
    attribute :received_events_url, :string
    attribute :type, :string
    attribute :site_admin, :boolean
    attribute :name, :string
    attribute :company, :string
    attribute :blog, :string
    attribute :location, :string
    attribute :email, :string
    attribute :hireable, :boolean
    attribute :bio, :string
    attribute :twitter_username, :string
    attribute :public_repos, :integer
    attribute :public_gists, :integer
    attribute :followers, :integer
    attribute :following, :integer
    attribute :created_at, :naive_datetime
    attribute :updated_at, :naive_datetime
  end
end
