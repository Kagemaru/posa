defmodule Posa.Github.API.PaginatingAdapter do
  def run_finch(request), do: {request, paginate(request)}

  def paginate(request, response \\ nil, collection \\ [])

  def paginate(nil, response, collection) do
    collection =
      collection
      |> List.flatten()
      |> Enum.reverse()

    Req.Response.new(%{response | body: collection})
  end

  def paginate(request, _, collection) do
    response =
      request
      |> Req.merge(adapter: &Req.Steps.run_finch/1)
      |> Req.request!()

    new_request =
      if response.status == 200 && next_link(response) do
        Req.merge(request, url: next_link(response))
      end

    paginate(new_request, response, [response.body | collection])
  end

  def next_link(%Req.Response{} = response) do
    Req.Response.get_private(response, :github, %{})[:links][:next]
  end
end
