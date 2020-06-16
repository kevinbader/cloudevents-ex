defmodule Cloudevents.KafkaBinding.V_1_0.Decoder do
  @moduledoc false
  alias Cloudevents.Format

  @doc """
  Parses a Kafka message as a Cloudevent.

  See [content modes] for a description of the expected data layout.

  [content modes]: https://github.com/cloudevents/spec/blob/v1.0/kafka-protocol-binding.md#13-content-modes
  """
  @spec from_kafka_message(
          Cloudevents.kafka_body(),
          Cloudevents.kafka_headers()
        ) ::
          {:ok, Cloudevents.t()} | {:error, any}
  def from_kafka_message(kafka_body, kafka_headers) do
    case content_type(kafka_headers) do
      "application/cloudevents" -> parse_structured(kafka_body, "json")
      "application/cloudevents+" <> event_format -> parse_structured(kafka_body, event_format)
      "application/cloudevents-batch" <> _ -> {:error, :batch_mode_not_available_as_per_spec}
      event_format -> parse_binary(kafka_headers, kafka_body, event_format)
    end
  end

  # ---

  # In the binary content mode, the value of the event data is placed into the Kafka
  # message body as-is, with the datacontenttype attribute value declaring its media
  # type in the Kafka Content-Type header; all other event attributes are mapped to
  # Kafka headers.
  defp parse_binary(kafka_headers, data, event_format) do
    ctx_attrs = for {"ce_" <> key, val} <- kafka_headers, into: %{}, do: {key, val}

    ctx_attrs
    |> Map.merge(%{"datacontenttype" => event_format, "data" => data})
    |> Format.Decoder.Map.decode()
  end

  # ---

  # In the structured content mode, event metadata attributes and event data are placed
  # into the Kafka message body using an event format.
  defp parse_structured(kafka_body, event_format) do
    case event_format do
      "json" -> Format.Decoder.JSON.decode(kafka_body)
      other_encoding -> {:error, {:no_decoder_for_event_format, other_encoding}}
    end
  end

  # ---

  defp content_type(headers) do
    for({"content-type", content_type} <- headers, do: content_type)
    |> hd()
    |> String.downcase()
  end
end
