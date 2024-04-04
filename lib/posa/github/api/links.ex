defmodule Posa.Github.API.Links do
  @type request :: Req.Request.t()
  @type response :: Req.Response.t()
  @type options :: keyword()

  @doc """
  Extract Github Pagination Links

  ## Request Options

    * `:github_links` - if `true`, extracts navigation links. Defaults to `true`.
  """
  def attach(%Req.Request{} = request, options \\ []) do
    request
    |> Req.Request.register_options([:github_links])
    |> Req.Request.merge_options(options)
    |> Req.Request.append_response_steps(extract_links: &extract_github_links/1)
  end

  @spec extract_github_links({request, response}) :: {request, response}
  def extract_github_links({request, response}) do
    with true <- request.options[:github_links],
         [links | _] <- Req.Response.get_header(response, "link"),
         parsed <- parse_links(links) do
      {request, Req.Response.put_private(response, :github, %{links: parsed})}
    else
      _ -> {request, response}
    end
  end

  @spec parse_links(String.t()) :: map()
  def parse_links(links) do
    links
    |> String.split(",")
    |> Enum.map(&extract_links/1)
    |> Map.new()
  end

  @spec extract_links(String.t()) :: {atom(), String.t()}
  def extract_links(pair) do
    pair |> String.trim() |> String.split(";") |> extract_parts()
  end

  @spec extract_parts([String.t()]) :: {atom(), String.t()}
  def extract_parts([url, rel]) do
    {
      String.slice(rel, 6..-2//1) |> String.to_atom(),
      String.slice(url, 1..-2//1)
    }
  end
end
