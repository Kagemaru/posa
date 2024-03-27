defmodule Posa.Utils do
  @moduledoc """
  Utility functions for the Posa application.
  """
  def system_env(key), do: system_env(key, "", nil)
  def system_env(key, type) when is_atom(type), do: system_env(key, "", type)
  def system_env(key, default), do: system_env(key, default, nil)
  def system_env(key, default, type), do: System.get_env(key, default) |> to_type(type)

  def to_type(value, :boolean), do: to_bool(value)
  def to_type(value, :array), do: to_array(value)
  def to_type(value, :atom), do: to_atom(value)
  def to_type(value, :existing_atom), do: to_existing_atom(value)
  def to_type(value, :integer), do: to_int(value)
  def to_type(value, _), do: value

  def to_bool(value) when value in ~w[1 true on], do: true
  def to_bool(_), do: false

  def to_array(value) when is_binary(value), do: String.split(value, ",")
  def to_array(value) when is_list(value), do: value
  def to_array(_), do: []

  def to_existing_atom(value) when is_binary(value), do: String.to_existing_atom(value)
  def to_existing_atom(value) when is_atom(value), do: value
  def to_existing_atom(_), do: nil

  def to_atom(value) when is_binary(value), do: String.to_atom(value)
  def to_atom(value) when is_atom(value), do: value
  def to_atom(_), do: nil

  def to_int(value) when is_binary(value), do: String.to_integer(value)
  def to_int(value) when is_integer(value), do: value
  def to_int(_), do: nil
end
