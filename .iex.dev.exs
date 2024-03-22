defmodule CustomIEx do
  def env, do: "dev"
  def color, do: IO.ANSI.green()
end

# :wx and :runtime_tools Not needed from OTP27 onwards
Mix.ensure_application!(:wx)
Mix.ensure_application!(:runtime_tools)
Mix.ensure_application!(:observer)
