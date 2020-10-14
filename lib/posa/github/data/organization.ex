defmodule Posa.Github.Data.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields ~w(login github_id url repos_url events_url hooks_url issues_url members_url public_members_url avatar_url description name blog location email public_repos public_gists followers following html_url created_at type)a
  @optional_fields ~w()a

  @primary_key false
  embedded_schema do
    field :login,              :string
    field :github_id,          :integer
    field :url,                :string
    field :repos_url,          :string
    field :events_url,         :string
    field :hooks_url,          :string
    field :issues_url,         :string
    field :members_url,        :string
    field :public_members_url, :string
    field :avatar_url,         :string
    field :description,        :string
    field :name,               :string
    field :blog,               :string
    field :location,           :string
    field :email,              :string
    field :public_repos,       :integer
    field :public_gists,       :integer
    field :followers,          :integer
    field :following,          :integer
    field :html_url,           :string
    field :created_at,         :naive_datetime
    field :type,               :string
  end

  def changeset(schema, params \\ :empty) do
    schema
    |> cast(params, @required_fields, @optional_fields)
  end
end
