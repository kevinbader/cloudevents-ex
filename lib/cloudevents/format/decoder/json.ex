defmodule Cloudevents.Format.Decoder.JSON do
  @moduledoc false
  alias Cloudevents.Format.Decoder.DecodeError
  alias Cloudevents.Format.V_1_0

  @doc "Decodes a JSON string to a Cloudevent."
  @callback decode(json :: String.t()) ::
              {:ok, Cloudevents.cloudevent()} | {:error, %DecodeError{}}

  @doc "Decodes a JSON string to a Cloudevent."
  @spec decode(json :: String.t()) :: {:ok, Cloudevents.t()} | {:error, %DecodeError{}}
  def decode(json) do
    with {:error, _} = error <- V_1_0.Decoder.JSON.decode(json) do
      error
    else
      {:ok, event} -> {:ok, event}
    end
  end
end
