defmodule Posa.Github.Etag do
  use Ash.Resource, domain: Posa.Github, data_layer: Ash.DataLayer.Ets

  actions do
    defaults [:destroy]

    read :get do
      argument :domain, :term, default: General
      argument :key, :term, allow_nil?: false
      get_by [:domain, :key]
    end

    read :get_all, primary?: true

    create :set do
      accept [:domain, :key, :etag]
      primary? true
      upsert? true
    end

    action :clear, :map do
      argument :domain, :term, default: General
      argument :key, :term, allow_nil?: false

      run fn input, _ ->
        with {:ok, resource} <- get(input.arguments) do
          {:ok, :deleted}
        else
          _ -> {:err, :not_found}
        end
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
    define :get_all, action: :get_all
    define :get, action: :get
    define :set, action: :set
    define :clear_all, action: :clear_all
    define :clear, action: :clear
  end

  attributes do
    attribute :domain, :term do
      default General
      allow_nil? false
      primary_key? true
      public? true
    end

    attribute :key, :term do
      allow_nil? false
      primary_key? true
      public? true
    end

    attribute :etag, :string do
      allow_nil? false
      public? true
    end
  end
end
