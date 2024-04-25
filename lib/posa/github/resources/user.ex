defmodule Posa.Github.User do
  use Ash.Resource,
    domain: Posa.Github,
    data_layer: Ash.DataLayer.Ets,
    notifiers: Ash.Notifier.PubSub

  require Logger

  alias Posa.Github.{API, Event, Member, Organization}

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    action :count, :integer, run: fn _, _ -> Ash.count(__MODULE__) end

    action :sync, {:array, :struct} do
      run fn _, _ ->
        try do
          for user <- __MODULE__.read!() do
            case API.user(user.login) do
              {:ok, user} ->
                __MODULE__.update!(user)

              {:err, "Forbidden"} ->
                Logger.info("Users sync error: Forbidden")
                throw(:forbidden)

              {:err, message} ->
                Logger.info("Users sync error: #{message}")
                nil
            end
          end
        catch
          :forbidden -> []
        end
        |> List.flatten()
        |> then(&{:ok, &1})
      end
    end
  end

  code_interface do
    define :create, action: :create
    define :read, action: :read
    define :update, action: :update
    define :destroy, action: :destroy

    define :count, action: :count
    define :sync, action: :sync
  end

  attributes do
    integer_primary_key :id, writable?: true, public?: true

    attribute :login, :string, writable?: true, public?: true
    attribute :node_id, :string, writable?: true, public?: true
    attribute :avatar_url, :string, writable?: true, public?: true
    attribute :gravatar_id, :string, writable?: true, public?: true
    attribute :url, :string, writable?: true, public?: true
    attribute :html_url, :string, writable?: true, public?: true
    attribute :followers_url, :string, writable?: true, public?: true
    attribute :following_url, :string, writable?: true, public?: true
    attribute :gists_url, :string, writable?: true, public?: true
    attribute :starred_url, :string, writable?: true, public?: true
    attribute :subscriptions_url, :string, writable?: true, public?: true
    attribute :organizations_url, :string, writable?: true, public?: true
    attribute :repos_url, :string, writable?: true, public?: true
    attribute :events_url, :string, writable?: true, public?: true
    attribute :received_events_url, :string, writable?: true, public?: true
    attribute :type, :string, writable?: true, public?: true
    attribute :site_admin, :boolean, writable?: true, public?: true
    attribute :name, :string, writable?: true, public?: true
    attribute :company, :string, writable?: true, public?: true
    attribute :blog, :string, writable?: true, public?: true
    attribute :location, :string, writable?: true, public?: true
    attribute :email, :string, writable?: true, public?: true
    attribute :hireable, :boolean, writable?: true, public?: true
    attribute :bio, :string, writable?: true, public?: true
    attribute :twitter_username, :string, writable?: true, public?: true
    attribute :public_repos, :integer, writable?: true, public?: true
    attribute :public_gists, :integer, writable?: true, public?: true
    attribute :followers, :integer, writable?: true, public?: true
    attribute :following, :integer, writable?: true, public?: true
    attribute :created_at, :naive_datetime, writable?: true, public?: true
    attribute :updated_at, :naive_datetime, writable?: true, public?: true
  end

  relationships do
    many_to_many :organizations, Organization do
      through Member
      source_attribute_on_join_resource :user_id
      destination_attribute_on_join_resource :organization_id
    end

    has_many :events, Event
  end

  pub_sub do
    module PosaWeb.Endpoint
    prefix "github"

    publish_all :create, "activity"
    publish_all :update, "activity"
    publish_all :destroy, "activity"

    publish_all :create, ["user", [nil, "created"], [nil, :id]]
    publish_all :update, ["user", [nil, "updated"], [nil, :id]], previous_values?: true
    publish_all :destroy, ["user", [nil, "destroyed"], [nil, :id]]

    # publish :sync, ["user", [nil, "synched"], [nil, :id]], previous_values?: true, event: "sync"
  end
end
