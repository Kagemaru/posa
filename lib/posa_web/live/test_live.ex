defmodule PosaWeb.TestLive do
  use PosaWeb, :live_view

  def render(assigns) do
    ~L"""
    <details>
      <summary>Summary 1</summary>
      <details>
        <summary>Summary 2</summary>
        <p>Test</p>
      </details>
    </details>
    """
  end
end
