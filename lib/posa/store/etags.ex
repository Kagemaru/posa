defmodule Posa.Store.Etags do
  use Posa.Store.Base

  def get_etag(domain),            do: _get(&get_in(&1, [domain]))
  def get_etag(domain, key),       do: _get(&get_in(&1, [domain, key]))
  def put_etag(domain, data),      do: _update(&put_in_p(&1, [domain], data))
  def put_etag(domain, key, data), do: _update(&put_in_p(&1, [domain, key], data))
end
