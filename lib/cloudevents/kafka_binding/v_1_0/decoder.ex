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
    IO.inspect(kafka_headers, label: "from_kafka_message")
    IO.inspect(content_type(kafka_headers), label: "content_type")

    case content_type(kafka_headers) do
      "application/cloudevents" ->
        parse_structured(kafka_body, "json")

      "application/cloudevents+avro" ->
        parse_binary(kafka_headers, kafka_body, :avro)

      "application/cloudevents+" <> event_format ->
        parsed_event_format = event_format |> String.split(";") |> List.first()
        parse_structured(kafka_body, parsed_event_format)

      "application/cloudevents-batch" <> _ ->
        {:error, :batch_mode_not_available_as_per_spec}

      nil ->
        parse_structured(kafka_body, "json")

      event_format ->
        parse_binary(kafka_headers, kafka_body, event_format)
    end
  end

  # ---

  defp parse_binary(kafka_headers, data, :avro) do
    ctx_attrs = for {"ce_" <> key, val} <- kafka_headers, into: %{}, do: {key, val}
    Cloudevents.from_avro(data, ctx_attrs)
  end

  defp parse_binary(kafka_headers, data, event_format) do
    ctx_attrs = for {"ce_" <> key, val} <- kafka_headers, into: %{}, do: {key, val}

    ctx_attrs
    |> Map.merge(%{
      "datacontenttype" => event_format,
      "data" => data |> try_decoding(event_format)
    })
    |> Format.Decoder.Map.decode()
  end

  # ---

  defp try_decoding(data, mimetype)

  defp try_decoding(data, "application/json" <> _) do
    case Jason.decode(data) do
      {:ok, decoded} -> decoded
      _ -> data
    end
  end

  defp try_decoding(data, _), do: data

  # ---

  defp parse_structured(<<0::8, _id::32, _body::binary>> = kafka_body, _event_format) do
    Cloudevents.from_avro(kafka_body, %{})
  end

  defp parse_structured(kafka_body, event_format) do
    case event_format do
      "json" -> Format.Decoder.JSON.decode(kafka_body)
      other_encoding -> {:error, {:no_decoder_for_event_format, other_encoding}}
    end
  end

  # ---

  defp content_type(headers) do
    content_type = for({"content-type", content_type} <- headers, do: content_type)

    if length(content_type) == 1 do
      content_type
      |> hd()
      |> String.downcase()
    else
      nil
    end
  end
end
