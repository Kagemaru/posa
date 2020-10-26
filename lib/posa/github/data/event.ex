defmodule Posa.Github.Data.Event do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields ~w(user_id github_id type actor org repo payload public created_at)a
  @optional_fields ~w()a

  @primary_key false
  embedded_schema do
    field :user_id, :integer
    field :github_id, :string
    field :type, :string
    field :actor, :map
    field :org, :map
    field :repo, :map
    field :payload, :map
    field :public, :boolean, default: false
    field :created_at, :naive_datetime
  end

  def changeset(schema, params \\ %{}) do
    schema
    |> cast(params, @required_fields, @optional_fields)
  end
end
