defmodule Posa.GithubOld.Storage.Users do
  @moduledoc "User storage"

  use Posa.GithubOld.Storage.Base

  def count, do: get_all() |> Enum.count()
end
