# Copyright 2020 Kevin Bader
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

defmodule Cloudevents do
  @moduledoc """
  Cloudevents implementation for Elixir. This is the main module.
  """
  alias Cloudevents.Format
  alias Cloudevents.HttpBinding

  @type cloudevent :: Format.V_1_0.Event.t() | Format.V_0_2.Event.t() | Format.V_0_1.Event.t()

  # @spec from_map(map()) :: cloudevent_result()
  # defdelegate from_map(map), to: Cloudevents.Parser.Map, as: :parse

  @doc "Decodes a JSON-encoded Cloudevent."
  @spec from_json(json :: binary()) ::
          {:ok, cloudevent()} | {:error, %Cloudevents.Format.Decoder.DecodeError{}}
  defdelegate from_json(json), to: Format.Decoder.JSON, as: :decode

  @doc "Encodes a Cloudevents using JSON format."
  @spec to_json(cloudevent()) :: binary()
  defdelegate to_json(cloudevent), to: Format.Encoder.JSON, as: :encode

  # # TODO: Add a callback for obtaining the Avro schema.
  # @spec from_avro(avro :: binary()) :: cloudevent_result()
  # defdelegate from_avro(avro), to: Cloudevents.Parser.Avro, as: :parse

  @type http_body :: binary()
  @type http_headers :: [{String.t(), String.t()}]
  @doc ~S"""
  Converts a HTTP request into one or more Cloudevents.

  Note that the HTTP request could contain more than one event (called a "batch"). Because of this, the function always returns a _list_ of Cloudevents. Use pattern matching if you expect single events only:

      with {:ok, [the_event]} = from_http_message(body, headers) do
        "do something with the_event"
      else
        {:ok, events} -> "oops got a batch of events"
        {:error, error} -> "failed to parse HTTP request: #{inspect(error)}"
      end
  """
  @spec from_http_message(http_body, http_headers) ::
          {:ok, [cloudevent()]} | {:error, Cloudevents.ParseError.t()}
  defdelegate from_http_message(http_body, http_headers), to: HttpBinding.Decoder

  @doc "Serialize an event in HTTP binary content mode."
  @spec to_binary_http_message(cloudevent()) :: {http_body, http_headers}
  defdelegate to_binary_http_message(event), to: HttpBinding.V_1_0.Encoder

  @doc "Serialize an event in HTTP structured content mode."
  @spec to_structured_http_message(cloudevent(), event_format :: :json) ::
          {http_body, http_headers}
  defdelegate to_structured_http_message(event, event_format),
    to: HttpBinding.V_1_0.Encoder

  # @doc "Serialize one or more events in HTTP batched content mode."
  # @spec to_batched_http_message([cloudevent()]) :: {http_body, http_headers}
  # defdelegate to_batched_http_message(events), to: HttpBinding.V_1_0.Encoder

  # @type kafka_body :: binary()
  # @type kafka_headers :: [{String.t(), String.t()}]
  # @spec from_kafka_message(kafka_body, kafka_headers) :: cloudevent_result()

  # @type kafka_content_mode :: :binary | :structured
  # @spec to_kafka_message(cloudevent(), :binary) :: {kafka_body, kafka_headers}
  # @spec to_kafka_message(cloudevent(), :structured, event_format :: :json | :avro) ::
  #         {kafka_body, kafka_headers}
end
