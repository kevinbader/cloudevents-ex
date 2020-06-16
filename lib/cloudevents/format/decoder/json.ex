defmodule Cloudevents.Format.Decoder.JSON do
  @moduledoc false
  alias Cloudevents.Format.Decoder.DecodeError
  alias Cloudevents.Format.V_0_2
  alias Cloudevents.Format.V_1_0

  @doc "Decodes a JSON string to a Cloudevent."
  @callback decode(json :: String.t()) ::
              {:ok, Cloudevents.t()} | {:error, %DecodeError{}}

  @doc "Decodes a JSON string to a Cloudevent."
  @spec decode(json :: String.t()) :: {:ok, Cloudevents.t()} | {:error, %DecodeError{}}
  def decode(json) when byte_size(json) > 0 do
    with {:error, error_1_0} <- V_1_0.Decoder.JSON.decode(json),
         {:error, error_0_2} <- V_0_2.Decoder.JSON.decode(json) do
      {:error, %DecodeError{cause: [error_1_0, error_0_2]}}
    else
      {:ok, event} -> {:ok, event}
    end
  end
end
