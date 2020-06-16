defmodule Cloudevents.HttpBinding.V_1_0.Decoder do
  @moduledoc false
  alias Cloudevents.Format

  @doc """
  Parses a HTTP request as one or more Cloudevents.

  See [content modes] for a description of the expected data layout.

  [content modes]: https://github.com/cloudevents/spec/blob/v1.0/http-protocol-binding.md#13-content-modes
  """
  @spec from_http_message(
          Cloudevents.http_body(),
          Cloudevents.http_headers()
        ) ::
          {:ok, [Cloudevents.t()]} | {:error, any}
  def from_http_message(http_body, http_headers) do
    case content_type(http_headers) do
      "application/cloudevents" -> parse_structured(http_body, "json")
      "application/cloudevents+" <> event_format -> parse_structured(http_body, event_format)
      "application/cloudevents-batch" -> parse_batched(http_body, "json")
      "application/cloudevents-batch+" <> event_format -> parse_batched(http_body, event_format)
      event_format -> parse_binary(http_headers, http_body, event_format)
    end
  end

  # ---

  # In the binary content mode, the value of the event data is placed into the HTTP
  # request, or response, body as-is, with the datacontenttype attribute value declaring
  # its media type in the HTTP Content-Type header; all other event attributes are
  # mapped to HTTP headers.
  defp parse_binary(http_headers, data, event_format) do
    ctx_attrs = for {"ce-" <> key, val} <- http_headers, into: %{}, do: {key, val}

    ctx_attrs
    |> Map.merge(%{"datacontenttype" => event_format, "data" => data})
    |> Format.Decoder.Map.decode()
    |> case do
      {:ok, event} -> {:ok, [event]}
      error_tuple -> error_tuple
    end
  end

  # ---

  # In the structured content mode, event metadata attributes and event data are placed
  # into the HTTP request or response body using an event format.
  defp parse_structured(http_body, event_format) do
    case event_format do
      "json" -> Format.Decoder.JSON.decode(http_body)
      other_encoding -> {:error, {:no_decoder_for_event_format, other_encoding}}
    end
    |> case do
      {:ok, event} -> {:ok, [event]}
      error_tuple -> error_tuple
    end
  end

  # ---

  # In the batched content mode several events are batched into a single HTTP request or
  # response body using an event format that supports batching.
  defp parse_batched(_http_body, _event_format) do
    # TODO
    {:error, :batch_mode_not_implemented}
  end

  # ---

  defp content_type(headers) do
    for({"content-type", content_type} <- headers, do: content_type)
    |> hd()
    |> String.downcase()
  end
end
