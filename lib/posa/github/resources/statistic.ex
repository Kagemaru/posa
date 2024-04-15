defmodule Posa.Github.Statistic do
  use Ash.Resource,
    domain: Posa.Github,
    data_layer: Ash.DataLayer.Ets,
    notifiers: [Ash.Notifier.PubSub]

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    action :as_map, :map do
      run fn _, _ ->
        Ash.read!(__MODULE__)
        |> Enum.into(%{}, &{&1.name, &1.value})
        |> then(&{:ok, &1})
      end
    end
  end

  code_interface do
    define :as_map, action: :as_map
    define :calculate, action: :create
  end

  attributes do
    attribute :key, :atom, writable?: true, allow_nil?: false, primary_key?: true, public?: true
    attribute :name, :string, public?: true
    attribute :value, :term, public?: true
  end

  pub_sub do
    module PosaWeb.Endpoint
    prefix "github"

    publish_all :create, ["statistic", [nil, "created"], [nil, :id]]

    publish_all :update, ["statistic", [nil, "updated"], [nil, :id]], previous_values?: true

    publish_all :destroy, ["statistic", [nil, "destroyed"], [nil, :id]]

    # publish :sync, ["statistic", [nil, "synched"], [nil, :id]], previous_values?: true, event: "sync"
  end
end
