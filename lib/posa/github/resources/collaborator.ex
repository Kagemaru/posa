defmodule Posa.Github.Collaborator do
  require Logger
  use Ash.Resource, domain: Posa.Github, data_layer: Ash.DataLayer.Ets

  alias Posa.Github.API
  alias Posa.Github.Repository
  alias Posa.Github.User

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    action :sync, {:array, :struct} do
      run fn _, _ ->
        for repo <- Repository.read!(load: :organization) do
          collaborators =
            case API.repo_collaborators(repo.organization.login, repo.name) do
              {:ok, repos} ->
                repos

              {:error, message} ->
                Logger.info("Collaborator sync error: #{message}")
                []
            end

          repo
          |> Ash.Changeset.for_update(:update)
          |> Ash.Changeset.manage_relationship(
            :collaborators,
            collaborators,
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
    define :read, action: :read
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
