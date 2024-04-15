defmodule Posa.Github.Member do
  use Ash.Resource,
    domain: Posa.Github,
    data_layer: Ash.DataLayer.Ets,
    notifiers: [Ash.Notifier.PubSub]

  require Logger

  alias Posa.Github.API
  alias Posa.Github.Organization
  alias Posa.Github.User

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    action :sync, {:array, :struct} do
      run fn _, _ ->
        for org <- Organization.read!() do
          members =
            case API.org_members(org.login) do
              {:ok, members} ->
                members

              {:error, message} ->
                Logger.info("Members sync error: #{message}")
                []
            end

          org
          |> Ash.Changeset.for_update(:update)
          |> Ash.Changeset.manage_relationship(
            :members,
            members,
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

    define :sync, action: :sync
  end

  attributes do
  end

  relationships do
    belongs_to :organization, Organization do
      attribute_type :integer
      primary_key? true
      allow_nil? false
    end

    belongs_to :user, User do
      attribute_type :integer
      primary_key? true
      allow_nil? false
    end
  end

  pub_sub do
    module PosaWeb.Endpoint
    prefix "github"

    publish_all :create, "activity"
    publish_all :update, "activity"
    publish_all :destroy, "activity"

    publish_all :create, ["member", [nil, "created"], [nil, :_pkey]]
    publish_all :update, ["member", [nil, "updated"], [nil, :_pkey]], previous_values?: true
    publish_all :destroy, ["member", [nil, "destroyed"], [nil, :_pkey]]

    # publish :sync, ["member", [nil, "synched"], [nil, :_pkey]], previous_values?: true, event: "sync"
  end
end
