defmodule Posa.Github.Storage.Users do
  @moduledoc "User storage"

  use Posa.Github.Storage.Base

  def count, do: get_all() |> Enum.count()
end
