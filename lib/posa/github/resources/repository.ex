defmodule Posa.Github.Repository do
  require Logger

  use Ash.Resource,
    domain: Posa.Github,
    data_layer: Ash.DataLayer.Ets,
    notifiers: [Ash.Notifier.PubSub]

  alias Posa.Github.API
  alias Posa.Github.Collaborator
  alias Posa.Github.Organization
  alias Posa.Github.User

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    action :count, :integer, run: fn _, _ -> Ash.count(__MODULE__) end

    action :sync, {:array, :struct} do
      run fn _, _ ->
        for org <- Organization.read!() do
          repos =
            case API.org_repositories(org.login) do
              {:ok, repos} ->
                repos

              {:error, message} ->
                Logger.info("Repos sync error: #{message}")
                []
            end

          org
          |> Ash.Changeset.for_update(:update)
          |> Ash.Changeset.manage_relationship(
            :repositories,
            repos,
            on_no_match: :create,
            on_lookup: :relate_and_update,
            on_match: :update,
            on_missing: :unrelate
          )
          |> Ash.update!()
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
    integer_primary_key :id, writable?: true

    attribute :name, :string, writable?: true, public?: true
  end

  relationships do
    belongs_to :organization, Organization, attribute_type: :integer

    many_to_many :collaborators, User do
      through Collaborator
      source_attribute_on_join_resource :repository_id
      destination_attribute_on_join_resource :user_id
    end
  end

  pub_sub do
    module PosaWeb.Endpoint
    prefix "github"

    publish_all :create, "activity"
    publish_all :update, "activity"
    publish_all :destroy, "activity"

    publish_all :create, ["repository", [nil, "created"], [nil, :id]]

    publish_all :update, ["repository", [nil, "updated"], [nil, :id]], previous_values?: true

    publish_all :destroy, ["repository", [nil, "destroyed"], [nil, :id]]

    # publish :sync, ["repository", [nil, "synched"], [nil, :id]], previous_values?: true, event: "sync"
  end
end
