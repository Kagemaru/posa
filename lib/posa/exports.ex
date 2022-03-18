defmodule Posa.Exports do
  @moduledoc """
  This Module controls the access to the Export methods.
  """
  alias Posa.Exports.Metrics

  def event_metrics, do: Metrics.all_metrics()
end
