defmodule Posa.GithubOld.Storage.Organizations do
  @moduledoc "Organization storage"

  use Posa.GithubOld.Storage.Base

  def count, do: get_all() |> Enum.count()
end
