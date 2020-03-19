defmodule Cloudevents.Format.Decoder.Map do
  @moduledoc false
  alias Cloudevents.Format.V_1_0
  alias Cloudevents.Format.V_1_0.Event.ParseError

  @doc "Converts an Elixir map to a Cloudevent."
  @spec decode(map) :: {:ok, Cloudevents.t()} | {:error, %ParseError{}}
  def decode(map) do
    # We allow atoms here as well, but the `from_map` functions only deal with strings:
    map = for {k, v} <- map, into: %{}, do: {if(is_binary(k), do: k, else: Atom.to_string(k)), v}

    with {:error, _} = error <- V_1_0.Event.from_map(map) do
      error
    else
      {:ok, event} -> {:ok, event}
    end
  end
end
