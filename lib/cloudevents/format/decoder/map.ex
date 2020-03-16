defmodule Cloudevents.Format.Decoder.Map do
  @moduledoc false
  alias Cloudevents.Format.V_1_0

  @doc "Converts an Elixir map to a Cloudevent."
  @spec decode(map()) :: {:ok, Cloudevents.cloud_event()} | {:error, any}
  def decode(map) do
    with {:error, _} = error <- V_1_0.Event.from_map(map) do
      error
    else
      {:ok, event} -> {:ok, event}
    end
  end
end
