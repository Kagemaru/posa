defmodule Posa.Github.Organization do
  use Ash.Resource, domain: Posa.Github, data_layer: Ash.DataLayer.Ets

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  attributes do
    integer_primary_key :id

    attribute :login, :string
    attribute :node_id, :string
    attribute :url, :string
    attribute :repos_url, :string
    attribute :events_url, :string
    attribute :hooks_url, :string
    attribute :issues_url, :string
    attribute :members_url, :string
    attribute :public_members_url, :string
    attribute :avatar_url, :string
    attribute :description, :string
    attribute :name, :string
    attribute :company, :string
    attribute :blog, :string
    attribute :location, :string
    attribute :email, :string
    attribute :twitter_username, :string
    attribute :is_verified, :boolean
    attribute :has_organization_projects, :boolean
    attribute :has_repository_projects, :boolean
    attribute :public_repos, :integer
    attribute :public_gists, :integer
    attribute :followers, :integer
    attribute :following, :integer
    attribute :html_url, :string
    attribute :created_at, :naive_datetime
    attribute :type, :string
    attribute :total_private_repos, :integer
    attribute :owned_private_repos, :integer
    attribute :private_gists, :integer
    attribute :disk_usage, :integer
    attribute :collaborators, :integer
    attribute :billing_email, :string

    attribute :plan, :map do
      constraints fields: [
                    name: [type: :string],
                    space: [type: :integer],
                    private_repos: [type: :integer],
                    filled_seats: [type: :integer],
                    seats: [type: :integer]
                  ]
    end

    attribute :default_repository_permission, :string
    attribute :members_can_create_repositories, :boolean
    attribute :two_factor_requirement_enabled, :boolean
    attribute :members_allowed_repository_creation_type, :string
    attribute :members_can_create_public_repositories, :boolean
    attribute :members_can_create_private_repositories, :boolean
    attribute :members_can_create_internal_repositories, :boolean
    attribute :members_can_create_pages, :boolean
    attribute :members_can_create_public_pages, :boolean
    attribute :members_can_create_private_pages, :boolean
    attribute :members_can_fork_private_repositories, :boolean
    attribute :web_commit_signoff_required, :boolean
    attribute :updated_at, :naive_datetime
    attribute :dependency_graph_enabled_for_new_repositories, :boolean
    attribute :dependabot_alerts_enabled_for_new_repositories, :boolean
    attribute :dependabot_security_updates_enabled_for_new_repositories, :boolean
    attribute :advanced_security_enabled_for_new_repositories, :boolean
    attribute :secret_scanning_enabled_for_new_repositories, :boolean
    attribute :secret_scanning_push_protection_enabled_for_new_repositories, :boolean
    attribute :secret_scanning_push_protection_custom_link, :string
    attribute :secret_scanning_push_protection_custom_link_enabled, :boolean
  end
end
