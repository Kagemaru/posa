defmodule Posa.Github.Storage.Organizations do
  @moduledoc "Organization storage"

  use Posa.Github.Storage.Base

  def count, do: get_all() |> Enum.count()
end
