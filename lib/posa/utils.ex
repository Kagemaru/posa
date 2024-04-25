defmodule Posa.Utils do
  @moduledoc """
  Utility functions for the Posa application.
  """

  import Kernel, except: [to_string: 1]

  # Types

  @type key :: String.t()
  @type type :: :list | :atom | :integer | :boolean | :existing_atom | nil
  @type value :: any()
  @type default :: value()
  @type return :: value()

  # Public functions

  @doc ~S"""
  """
  @spec month_tag(Date.t()) :: map()
  def month_tag(date) do
    date = date |> Date.beginning_of_month()

    %{
      date: date,
      machine: Timex.format!(date, "{YYYY}-{0M}"),
      month_label: Timex.lformat!(date, "{Mfull}", "de"),
      year_label: Timex.format!(date, "{YYYY}")
    }
  end

  @doc ~S"""
  """
  @spec day_tag(DateTime.t()) :: map()
  def day_tag(%DateTime{} = date), do: day_tag(date |> DateTime.to_date())

  @spec day_tag(NaiveDateTime.t()) :: map()
  def day_tag(%NaiveDateTime{} = date), do: day_tag(date |> NaiveDateTime.to_date())

  @spec day_tag(Date.t()) :: map()
  def day_tag(%Date{} = date) do
    %{
      date: date,
      machine: Timex.format!(date, "{YYYY}-{0M}-{0D}"),
      day_label: Timex.lformat!(date, "{WDfull}", "de"),
      date_label: Timex.format!(date, "{0D}.{0M}.{YYYY}")
    }
  end

  @doc ~S"""
  Tries to retrieve system env variables in order from the list of keys.
  If no key is found, the default value is returned.
  If a type is specified, the value is converted to that type.
  """
  @spec any([key()], default(), type()) :: return()
  def any(list, default \\ nil, type \\ nil) do
    list
    |> Enum.find_value(default, &system_env/1)
    |> to_type(type)
  end

  @doc ~S"""
  Get the system environment variable `key` and convert it to the specified `type`.

  ## Examples

      iex> Posa.Utils.system_env("PHX_ORGANIZATIONS", "puzzle", :list)
      ["puzzle"]

      iex> Posa.Utils.system_env("PHX_SYNC_DELAY_MS", 120, :integer)
      120000

      iex> Posa.Utils.system_env("PHX_INITIAL_SYNC", "true", :bool)
      true

      iex> Posa.Utils.system_env("PHX_DEBUG", "false", :bool)
      false
  """
  @spec system_env(key(), default(), type()) :: return()
  def system_env(key, default \\ nil, type \\ nil) when is_atom(nil) do
    System.get_env(key, default) |> to_type(type)
  end

  @doc ~S"""
  Convert the `value` to the specified `type`.
  """
  @spec to_type(value(), type()) :: return()
  def to_type(value, type \\ nil) do
    case type do
      :list -> to_list(value)
      :atom -> to_atom(value)
      :integer -> to_int(value)
      :boolean -> to_bool(value)
      :string -> to_string(value)
      :existing_atom -> to_existing_atom(value)
      t when t in ~w[bool boolean]a -> to_bool(value)
      _ -> value
    end
  end

  # Private functions

  @spec to_atom(value()) :: atom()
  defp to_atom(value) do
    case value do
      v when is_binary(v) -> String.to_atom(v)
      v when is_atom(v) -> v
      _ -> nil
    end
  end

  @spec to_bool(value()) :: boolean()
  defp to_bool(value) do
    case value do
      v when v in [1, true, "1", "true", "on", "yes"] -> true
      v when is_list(v) and length(v) > 0 -> true
      _ -> false
    end
  end

  @spec to_existing_atom(value()) :: atom()
  defp to_existing_atom(value) do
    case value do
      v when is_binary(v) -> String.to_existing_atom(v)
      v when is_atom(v) -> v
      _ -> nil
    end
  end

  @spec to_int(value()) :: integer()
  defp to_int(value) do
    case value do
      v when is_binary(v) and v != "" -> String.to_integer(v)
      v when is_integer(v) -> v
      _ -> 0
    end
  end

  @spec to_list(value()) :: list()
  defp to_list(value) do
    case value do
      v when is_binary(v) -> String.split(v, ",") |> List.wrap()
      v when is_list(v) -> v
      _ -> []
    end
  end

  @spec to_string(value()) :: String.t()
  defp to_string(value) do
    case value do
      v when is_binary(v) -> v
      v when is_list(v) -> Enum.join(v, ",")
      v when is_integer(v) -> Integer.to_string(v)
      _ -> ""
    end
  end
end
