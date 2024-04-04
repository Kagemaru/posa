defmodule Posa.GithubApi.Links do
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

  def extract_github_links({request, response}) do
    with true <- request.options[:github_links],
         links <- response.get_header("link"),
         parsed <- parse_links(links) do
      {
        request,
        response
        |> Req.Response.put_private(:github_links, parsed)
      }
    else
      _ -> {request, response}
    end
  end

  def parse_links(links) do
    links
    |> String.split(",")
    |> Enum.map(&extract_links/1)
    |> Map.new()
  end

  def extract_links(pair) do
    String.trim(pair) |> String.split(";") |> extract_parts()
  end

  def extract_parts([url, rel]) do
    {
      String.slice(rel, 6..-2//1) |> String.to_atom(),
      String.slice(url, 1..-2//1)
    }
  end
end
