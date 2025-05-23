defmodule Posa.Github.Organization do
  @moduledoc """
  Represents a Github Organization.
  """

  use Ash.Resource,
    domain: Posa.Github,
    data_layer: Ash.DataLayer.Ets,
    notifiers: Ash.Notifier.PubSub

  require Logger

  alias Posa.Github.{API, Member, Repository, User}

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    action :count, :integer, run: fn _, _ -> Ash.count(__MODULE__) end

    action :sync, {:array, :struct} do
      run fn _, _ ->
        for org_name <- Application.fetch_env!(:posa, :organizations) do
          case API.organization(org_name) do
            {:ok, :not_modified} -> nil
            {:ok, org} -> __MODULE__.create!(org)
            {:err, message} -> Logger.info("Organization sync error: #{message}")
          end
        end
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
    attribute :url, :string, writable?: true, public?: true
    attribute :repos_url, :string, writable?: true, public?: true
    attribute :events_url, :string, writable?: true, public?: true
    attribute :hooks_url, :string, writable?: true, public?: true
    attribute :issues_url, :string, writable?: true, public?: true
    attribute :members_url, :string, writable?: true, public?: true
    attribute :public_members_url, :string, writable?: true, public?: true
    attribute :avatar_url, :string, writable?: true, public?: true
    attribute :description, :string, writable?: true, public?: true
    attribute :name, :string, writable?: true, public?: true
    attribute :company, :string, writable?: true, public?: true
    attribute :blog, :string, writable?: true, public?: true
    attribute :location, :string, writable?: true, public?: true
    attribute :email, :string, writable?: true, public?: true
    attribute :twitter_username, :string, writable?: true, public?: true
    attribute :is_verified, :boolean, writable?: true, public?: true
    attribute :has_organization_projects, :boolean, writable?: true, public?: true
    attribute :has_repository_projects, :boolean, writable?: true, public?: true
    attribute :public_repos, :integer, writable?: true, public?: true
    attribute :public_gists, :integer, writable?: true, public?: true
    attribute :followers, :integer, writable?: true, public?: true
    attribute :following, :integer, writable?: true, public?: true
    attribute :html_url, :string, writable?: true, public?: true
    attribute :created_at, :naive_datetime, writable?: true, public?: true

    attribute :type, :string, writable?: true, public?: true
    attribute :total_private_repos, :integer, writable?: true, public?: true
    attribute :owned_private_repos, :integer, writable?: true, public?: true
    attribute :private_gists, :integer, writable?: true, public?: true
    attribute :disk_usage, :integer, writable?: true, public?: true
    attribute :collaborators, :integer, writable?: true, public?: true
    attribute :billing_email, :string, writable?: true, public?: true

    attribute :plan, :map do
      writable? true
      public? true

      constraints fields: [
                    name: [type: :string],
                    space: [type: :integer],
                    private_repos: [type: :integer],
                    filled_seats: [type: :integer],
                    seats: [type: :integer]
                  ]
    end

    attribute :default_repository_permission, :string, writable?: true, public?: true
    attribute :members_can_create_repositories, :boolean, writable?: true, public?: true
    attribute :two_factor_requirement_enabled, :boolean, writable?: true, public?: true
    attribute :members_allowed_repository_creation_type, :string, writable?: true, public?: true
    attribute :members_can_create_public_repositories, :boolean, writable?: true, public?: true
    attribute :members_can_create_private_repositories, :boolean, writable?: true, public?: true
    attribute :members_can_create_internal_repositories, :boolean, writable?: true, public?: true
    attribute :members_can_create_pages, :boolean, writable?: true, public?: true
    attribute :members_can_create_public_pages, :boolean, writable?: true, public?: true
    attribute :members_can_create_private_pages, :boolean, writable?: true, public?: true
    attribute :members_can_fork_private_repositories, :boolean, writable?: true, public?: true
    attribute :web_commit_signoff_required, :boolean, writable?: true, public?: true
    attribute :updated_at, :naive_datetime, writable?: true, public?: true

    attribute :dependency_graph_enabled_for_new_repositories, :boolean,
      writable?: true,
      public?: true

    attribute :dependabot_alerts_enabled_for_new_repositories, :boolean,
      writable?: true,
      public?: true

    attribute :dependabot_security_updates_enabled_for_new_repositories, :boolean,
      writable?: true,
      public?: true

    attribute :advanced_security_enabled_for_new_repositories, :boolean,
      writable?: true,
      public?: true

    attribute :secret_scanning_enabled_for_new_repositories, :boolean,
      writable?: true,
      public?: true

    attribute :secret_scanning_push_protection_enabled_for_new_repositories, :boolean,
      writable?: true,
      public?: true

    attribute :secret_scanning_push_protection_custom_link, :string,
      writable?: true,
      public?: true

    attribute :secret_scanning_push_protection_custom_link_enabled, :boolean,
      writable?: true,
      public?: true

    attribute :archived_at, :naive_datetime, writable?: true, public?: true
  end

  relationships do
    many_to_many :members, User do
      through Member
      source_attribute_on_join_resource :organization_id
      destination_attribute_on_join_resource :user_id
    end

    has_many :repositories, Repository
  end

  pub_sub do
    module PosaWeb.Endpoint
    prefix "github"

    publish_all :create, "activity"
    publish_all :update, "activity"
    publish_all :destroy, "activity"

    publish_all :create, ["organization", [nil, "created"], [nil, :id]]
    publish_all :update, ["organization", [nil, "updated"], [nil, :id]], previous_values?: true
    publish_all :destroy, ["organization", [nil, "destroyed"], [nil, :id]]

    # publish :sync, ["organization", [nil, "synched"], [nil, :id]], previous_values?: true, event: "sync"
  end
end
