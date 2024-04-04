defmodule Posa.GithubApi.PaginatingAdapter do
  def adapter(request) do
    response = paginate(request)

    {request, response}
  end

  defp paginate(request, response \\ nil, collection \\ [])

  defp paginate(nil, response, collection) do
    Req.Response.new(%{response | body: collection})
  end

  defp paginate(request, _, collection) do
    response =
      request
      |> Req.merge(adapter: &Req.Steps.run_finch/1)
      |> Req.request!()

    new_request =
      if next_link(response) do
        Req.merge(request, url: next_link(response))
      end

    paginate(new_request, response, response.body ++ collection)
  end

  defp next_link(%Req.Response{} = response) do
    Req.Response.get_private(response, :github, %{})[:links][:next]
  end
end
