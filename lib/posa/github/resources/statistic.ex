defmodule Posa.Github.Statistic do
  alias Posa.Exports.Metrics

  use Ash.Resource,
    domain: Posa.Github,
    data_layer: Ash.DataLayer.Ets,
    notifiers: Ash.Notifier.PubSub

  actions do
    defaults [:read, :destroy, create: :*, update: :*]

    action :as_map, :map do
      run fn _, _ ->
        Ash.read!(__MODULE__)
        |> Enum.into(%{}, &{&1.name, &1.value})
        |> then(&{:ok, &1})
      end
    end

    action :calculate, :map do
      run fn _, _ ->
        if :ets.info(__MODULE__) == :undefined do
          clear_all!()
        else
          :ets.new(__MODULE__, [])
        end

        metrics = Metrics.all_metrics()

        time_ranges = [:month, :week, :day, :total]
        user_types = [:internal, :external, :total]
        event_types = [:commits, :issues, :reviews, :other, :total]

        for time_range <- time_ranges do
          for event_type <- event_types do
            for user_type <- user_types do
              counts = metrics[time_range][event_type][user_type]
              name = "#{time_range}_#{event_type}_#{user_type}"
              key = name |> String.to_atom()
              create!(%{key: key, name: name, value: counts})
            end
          end
        end

        for {key, value} <- metrics[:tags][:month] do
          create!(%{
            key: :"tags_month_#{key}",
            name: "tags_month_#{key}",
            value: value
          })
        end

        for {key, value} <- metrics[:tags][:day] do
          create!(%{
            key: :"tags_day_#{key}",
            name: "tags_day_#{key}",
            value: value
          })
        end

        {:ok, as_map!()}
      end
    end

    action :clear_all, :term do
      run(fn _, _ ->
        :ets.delete_all_objects(__MODULE__)
        {:ok, :deleted}
      end)
    end
  end

  code_interface do
    define :create, action: :create
    define :as_map, action: :as_map
    define :calculate, action: :calculate

    define :clear_all, action: :clear_all
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
