defmodule Cloudevents.Format.Decoder.Map do
  @moduledoc false
  alias Cloudevents.Format.Decoder.DecodeError
  alias Cloudevents.Format.V_0_1
  alias Cloudevents.Format.V_0_2
  alias Cloudevents.Format.V_1_0

  @doc "Converts an Elixir map to a Cloudevent."
  @spec decode(map) :: {:ok, Cloudevents.t()} | {:error, %DecodeError{}}
  def decode(map) when is_map(map) do
    # We allow atoms here as well, but the `from_map` functions only deal with strings:
    map = for {k, v} <- map, into: %{}, do: {if(is_binary(k), do: k, else: Atom.to_string(k)), v}

    with {:error, error_1_0} <- V_1_0.Event.from_map(map),
         {:error, error_0_2} <- V_0_2.Event.from_map(map),
         {:error, error_0_1} <- V_0_1.Event.from_map(map) do
      {:error, %DecodeError{cause: [error_1_0, error_0_2, error_0_1]}}
    else
      {:ok, event} -> {:ok, event}
    end
  end
end
