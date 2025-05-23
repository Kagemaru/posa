defmodule Posa.Github.Member do
  @moduledoc """
  Represents a Github Member
  """

  use Ash.Resource,
    domain: Posa.Github,
    data_layer: Ash.DataLayer.Ets,
    notifiers: Ash.Notifier.PubSub

  require Logger

  alias Posa.Github.{API, Organization, User}

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      argument :organization, :struct do
        allow_nil? false
        constraints instance_of: Organization
      end

      argument :user, :struct do
        allow_nil? false
        constraints instance_of: User
      end

      accept []
      primary? true

      change manage_relationship(:organization, :organization, type: :append)
      change manage_relationship(:user, :user, type: :append)
    end

    action :logins, {:array, :string} do
      run fn _, _ ->
        __MODULE__
        |> Ash.Query.load(:user)
        |> Ash.read!()
        |> Enum.map(& &1.user.login)
        |> then(&{:ok, &1})
      end
    end

    action :count, :integer, run: fn _, _ -> Ash.count(__MODULE__) end

    action :sync, {:array, :struct} do
      run fn _, _ ->
        for org <- Organization.read!() do
          case API.org_members(org.login) do
            {:ok, :not_modified} ->
              nil

            {:ok, users} ->
              for user <- users do
                %{organization: org, user: User.create!(user)}
                |> __MODULE__.create!()
              end

            {:err, message} ->
              Logger.info("Members sync error: #{message}")
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

    define :logins, action: :logins
    define :count, action: :count
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

    # publish_all :create, ["member", [nil, "created"], [nil, :_pkey]]
    # publish_all :update, ["member", [nil, "updated"], [nil, :_pkey]], previous_values?: true
    # publish_all :destroy, ["member", [nil, "destroyed"], [nil, :_pkey]]

    # publish :sync, ["member", [nil, "synched"], [nil, :_pkey]], previous_values?: true, event: "sync"
  end
end
