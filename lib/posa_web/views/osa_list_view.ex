defmodule PosaWeb.OSAListView do
  use PosaWeb, :view

  def make_it_json(input) do
    case Jason.encode(input) do
      {:ok, json} -> json
      _ -> "Nix"
    end
  end
end
