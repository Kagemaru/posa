defmodule Posa.Github.Collaborator do
  require Logger

  use Ash.Resource,
    domain: Posa.Github,
    data_layer: Ash.DataLayer.Ets,
    notifiers: Ash.Notifier.PubSub

  alias Posa.Github.{API, Repository, User}

  actions do
    defaults [:read, :destroy, update: :*]

    create :create do
      argument :repository, :struct do
        allow_nil? false
        constraints instance_of: Repository
      end

      argument :user, :struct do
        allow_nil? false
        constraints instance_of: User
      end

      accept []
      primary? true

      change manage_relationship(:repository, :repository, type: :create)
      change manage_relationship(:user, :user, type: :create)
    end

    action :count, :integer, run: fn _, _ -> Ash.count(__MODULE__) end

    action :sync, {:array, :struct} do
      run fn _, _ ->
        try do
          for repo <- Repository.read!(load: :organization) do
            case API.repo_collaborators(repo.organization.login, repo.name) do
              {:ok, users} ->
                for user <- users, do: __MODULE__.create!(%{repository: repo, user: user})

              {:err, "Forbidden"} ->
                Logger.info("Collaborator sync error: Forbidden")
                throw(:forbidden)

              {:err, message} ->
                Logger.info("Collaborator sync error: #{message}")
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

  relationships do
    belongs_to :repository, Repository do
      primary_key? true
      allow_nil? false
      attribute_type :integer
    end

    belongs_to :user, User do
      primary_key? true
      allow_nil? false
      attribute_type :integer
    end
  end
end
