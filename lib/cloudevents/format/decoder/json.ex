defmodule Cloudevents.Format.Decoder.JSON do
  @moduledoc false
  alias Cloudevents.Format.V_1_0

  @doc "Decodes a JSON string to a Cloudevent."
  @callback decode(json :: String.t()) :: {:ok, Cloudevents.cloud_event()} | {:error, any}

  @doc "Decodes a JSON string to a Cloudevent."
  @spec decode(json :: String.t()) :: {:ok, Cloudevents.cloud_event()} | {:error, any}
  def decode(json) do
    with {:error, _} = error <- V_1_0.Decoder.JSON.decode(json) do
      error
    else
      {:ok, event} -> {:ok, event}
    end
  end
end
