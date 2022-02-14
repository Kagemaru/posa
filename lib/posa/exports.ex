defmodule Posa.Exports do
  alias Posa.Exports.Metrics

  def event_metrics(), do: Metrics.all_metrics()
end
