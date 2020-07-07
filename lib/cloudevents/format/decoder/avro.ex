defmodule Cloudevents.Format.Decoder.Avro do
  @moduledoc false
  alias Cloudevents.Format.Decoder.DecodeError
  alias Cloudevents.Format.V_0_1
  alias Cloudevents.Format.V_0_2
  alias Cloudevents.Format.V_1_0

  @doc "Decodes an Avro binary to a Cloudevent."
  @callback decode(avro :: binary, ctx :: binary) ::
              {:ok, Cloudevents.t()} | {:error, %DecodeError{}}

  @doc "Decodes an Avro binary to a Cloudevent."
  @spec decode(avro :: binary, ctx :: binary) :: {:ok, Cloudevents.t()} | {:error, %DecodeError{}}
  def decode(avro, ctx) when byte_size(avro) > 0 do
    with {:error, error_1_0} <- V_1_0.Decoder.Avro.decode(avro, ctx),
         {:error, error_0_2} <- V_0_2.Decoder.Avro.decode(avro, ctx),
         {:error, error_0_1} <- V_0_1.Decoder.Avro.decode(avro, ctx) do
      {:error, %DecodeError{cause: [error_1_0, error_0_2, error_0_1]}}
    else
      {:ok, event} -> {:ok, event}
    end
  end
end
