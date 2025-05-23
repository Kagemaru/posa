defmodule Posa.Github.Repository do
  @moduledoc """
  Represents a Github Repository.
  """

  require Logger

  use Ash.Resource,
    domain: Posa.Github,
    data_layer: Ash.DataLayer.Ets,
    notifiers: Ash.Notifier.PubSub

  alias Posa.Github.{API, Collaborator, Organization, User}

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      argument :organization, :struct do
        constraints instance_of: Organization
      end

      accept [:id, :name]
      primary? true

      change manage_relationship(:organization, :organization, type: :append)
    end

    action :count, :integer, run: fn _, _ -> Ash.count(__MODULE__) end

    action :sync, {:array, :struct} do
      run fn _, _ ->
        for org <- Organization.read!() do
          case API.org_repositories(org.login) do
            {:ok, :not_modified} ->
              nil

            {:ok, repos} ->
              for repo <- repos do
                repo
                |> Map.take(["id", "name"])
                |> Map.put(:organization, org)
                |> __MODULE__.create!()
              end

            {:err, message} ->
              Logger.info("Repos sync error: #{message}")
              nil
          end
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
