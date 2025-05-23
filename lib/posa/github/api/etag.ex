defmodule Posa.Github.API.Etag do
  @moduledoc """
  Save and load etags

  ## Request Options

    * `:etags` - if `true`, saves and loads etags. Defaults to `false`.
    * `:etags_save_fun` - function to save etags. Defaults to `&save_etag/1`.
    * `:etags_load_fun` - function to load etags. Defaults to `&load_etag/1`.
  """

  alias Posa.Github.Etag

  def attach(%Req.Request{} = request, options \\ []) do
    request
    |> Req.Request.register_options([:etags, :etags_save_fun, :etags_load_fun])
    |> Req.Request.merge_options(options)
    |> Req.Request.prepend_request_steps(save_etags: &load_etags/1)
    |> Req.Request.append_response_steps(load_etags: &save_etags/1)
  end

  defp save_etags({request, response}) do
    if request.options[:etags] do
      fun = request.options[:save_fun] || (&save_etag/1)
      fun.({request, response})
    end

    {request, response}
  end

  defp save_etag({request, response}) do
    Etag.set(%{
      key: request.url |> URI.to_string(),
      etag: response |> Req.Response.get_header("etag") |> List.first()
    })
  end

  defp load_etags(request) do
    if request.options[:etags] do
      fun = request.options[:load_fun] || (&load_etag/1)
      fun.(request)
    else
      request
    end
  end

  defp load_etag(request) do
    url = "#{request.options.base_url}#{request.url |> URI.to_string()}"

    case Etag.get(%{key: url}) do
      {:ok, %{etag: etag}} -> Req.Request.put_header(request, "If-None-Match", etag)
      _ -> request
    end
  end
end
