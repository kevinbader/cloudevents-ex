defmodule Cloudevents.Format.V_0_1.Decoder.Avro do
  @moduledoc false
  @behaviour Cloudevents.Format.Decoder.Avro

  alias Cloudevents.Format.Decoder.DecodeError
  alias Cloudevents.Format.ParseError
  alias Cloudevents.Format.V_0_1.Event

  @doc "Decodes an Avro binary into a Cloudevent v0.1 struct."
  def decode(avro, ctx_attrs \\ %{}) do
    with {:decode, {:ok, map}} <- {:decode, unpack_decoded(Avrora.decode(avro))},
         {:parse, {:ok, event}} <- {:parse, try_parse_ctx_attrs(map, ctx_attrs)} do
      {:ok, event}
    else
      {:decode, {:error, %MatchError{}}} ->
        {:error, %DecodeError{cause: "Binary does not look like a valid Avro encoding"}}

      {:decode, {:error, {:failed_to_connect, connection_error}}} ->
        {:error,
         %DecodeError{
           cause: "Failed to connect to Confluent Schema Registry: #{inspect(connection_error)}"
         }}

      {:decode, {:error, other_error}} ->
        {:error, %DecodeError{cause: "Failed to decode Avro binary: #{inspect(other_error)}"}}

      {:parse, {:error, %ParseError{} = error}} ->
        {:error, %DecodeError{cause: error}}
    end
  end

  # ---

  defp try_parse_ctx_attrs(map, ctx_attrs) when ctx_attrs == %{} do
    Event.from_map(map)
  end

  defp try_parse_ctx_attrs(map, ctx_attrs) do
    ctx_attrs |> Map.merge(%{"data" => map}) |> Event.from_map()
  end

  # When the encoding uses the Avro Object Container File (OCF) format, the result is
  # always a list; since we expect a single map (= the event), we unpack it here.
  # Also, we fail if it's not a map or a list-wrapped map.
  defp unpack_decoded({:ok, [map]}) when is_map(map), do: {:ok, map}
  defp unpack_decoded({:ok, map}) when is_map(map), do: {:ok, map}
  defp unpack_decoded({:error, error}), do: {:error, error}
end
