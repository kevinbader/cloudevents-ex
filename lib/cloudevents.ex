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
  @moduledoc File.read!("README.md")

  alias Cloudevents.Format
  alias Cloudevents.HttpBinding
  alias Cloudevents.KafkaBinding

  @typedoc "Cloudevent"
  @type t :: Format.V_1_0.Event.t() | Format.V_0_2.Event.t() | Format.V_0_1.Event.t()

  @typedoc "Configuration parameters for encoding and decoding of data"
  @type options :: [option]

  @typedoc "Configuration parameter"
  @type option :: {:confluent_schema_registry_url, confluent_schema_registry_url}

  @typedoc "Confluent Schema Registry URL for resolving Avro schemas by ID"
  @type confluent_schema_registry_url :: String.t()

  @typedoc "HTTP body"
  @type http_body :: binary()

  @typedoc "HTTP headers"
  @type http_headers :: [{String.t(), String.t()}]

  @typedoc "Kafka body"
  @type kafka_body :: binary()

  @typedoc "Kafka headers"
  @type kafka_headers :: [{String.t(), String.t()}]

  @doc """
  Converts an Elixir map into a Cloudevent.

  ## Examples

      iex> Cloudevents.from_map(%{"specversion" => "1.0", "type" => "test", "source" => "test", "id" => "1"})
      {:ok,
       %Cloudevents.Format.V_1_0.Event{
         data: nil,
         datacontenttype: nil,
         dataschema: nil,
         extensions: %{},
         id: "1",
         source: "test",
         specversion: "1.0",
         subject: nil,
         time: nil,
         type: "test"
       }}

      iex> Cloudevents.from_map(%{specversion: "1.0", type: "test", source: "test", id: "1"})
      {:ok,
       %Cloudevents.Format.V_1_0.Event{
         data: nil,
         datacontenttype: nil,
         dataschema: nil,
         extensions: %{},
         id: "1",
         source: "test",
         specversion: "1.0",
         subject: nil,
         time: nil,
         type: "test"
       }}

  """
  @spec from_map(map :: %{required(atom) => any} | %{required(String.t()) => any}) ::
          {:ok, t()} | {:error, %Cloudevents.Format.V_1_0.Event.ParseError{}}
  defdelegate from_map(map), to: Format.Decoder.Map, as: :decode

  @doc "Converts an Elixir map into a Cloudevent and panics otherwise."
  @spec from_map!(map :: %{required(atom) => any} | %{required(String.t()) => any}) ::
          t()
  def from_map!(map) do
    {:ok, event} = from_map(map)
    event
  end

  # ---

  @doc """
  Converts a Cloudevent into an Elixir map. See also `Cloudevents.from_map/1`.

  ## Examples

      iex> Cloudevents.to_map(Cloudevents.from_map!(%{"specversion" => "1.0", "type" => "test", "source" => "test", "id" => "1"}))
      %{specversion: "1.0", type: "test", source: "test", id: "1"}

  """
  @spec to_map(t()) :: %{required(atom) => any}
  defdelegate to_map(cloudevent), to: Format.Encoder.Map, as: :convert

  # ---

  @doc "Decodes a JSON-encoded Cloudevent."
  @spec from_json(json :: binary()) ::
          {:ok, t()} | {:error, %Cloudevents.Format.Decoder.DecodeError{}}
  defdelegate from_json(json), to: Format.Decoder.JSON, as: :decode

  @doc "Decodes a JSON-encoded Cloudevent and panics otherwise."
  @spec from_json!(json :: binary()) :: t()
  def from_json!(json) do
    {:ok, event} = from_json(json)
    event
  end

  # ---

  @doc "Encodes a Cloudevents using JSON format."
  @spec to_json(t()) :: binary()
  defdelegate to_json(cloudevent), to: Format.Encoder.JSON, as: :encode

  # ---

  # @doc "Decodes an Avro-encoded Cloudevent."
  # @spec from_avro(avro :: binary(), confluent_schema_registry_url) ::
  #         {:ok, t()} | {:error, %Cloudevents.Format.Decoder.DecodeError{}}
  # defdelegate from_avro(avro, confluent_schema_registry_url), to: Format.Decoder.Avro, as: :decode

  # ---

  @doc ~S"""
  Parses a HTTP request as one or more Cloudevents.

  Note that the HTTP request may contain more than one event (called a "batch"). Because of this, the function always returns a _list_ of Cloudevents. Use pattern matching if you expect single events only:

      with {:ok, [the_event]} = from_http_message(body, headers) do
        "do something with the_event"
      else
        {:ok, events} -> "oops got a batch of events"
        {:error, error} -> "failed to parse HTTP request: #{inspect(error)}"
      end
  """
  @spec from_http_message(http_body, http_headers, options) ::
          {:ok, [t()]} | {:error, any}
  defdelegate from_http_message(http_body, http_headers, options \\ []), to: HttpBinding.Decoder

  # ---

  @doc """
  Serialize an event in HTTP binary content mode.

  Binary mode basically means: the payload is in the body and the metadata is in the header.

      iex> event = Cloudevents.from_map!(%{
      ...>   specversion: "1.0",
      ...>   type: "some-type",
      ...>   source: "some-source",
      ...>   id: "1",
      ...>   data: %{"foo" => "bar"}})
      iex> {body, headers} = Cloudevents.to_http_binary_message(event)
      {
        "{\\"foo\\":\\"bar\\"}",
        [
          {"content-type", "application/json"},
          {"ce-specversion", "1.0"},
          {"ce-type", "some-type"},
          {"ce-source", "some-source"},
          {"ce-id", "1"}
        ]
      }

  """
  @spec to_http_binary_message(t()) :: {http_body, http_headers}
  defdelegate to_http_binary_message(event),
    to: HttpBinding.V_1_0.Encoder,
    as: :to_binary_content_mode

  # ---

  @doc """
  Serialize an event in HTTP structured content mode.

  Structured mode basically means: the full event - payload and metadata - is in the body.
  """
  @spec to_http_structured_message(t(), event_format :: :json | :avro, options) ::
          {http_body, http_headers}
  defdelegate to_http_structured_message(event, event_format, options \\ []),
    to: HttpBinding.V_1_0.Encoder,
    as: :to_structured_content_mode

  # ---

  # @doc "Serialize one or more events in HTTP batched content mode."
  # @spec to_batched_http_message([t()]) :: {http_body, http_headers}
  # defdelegate to_batched_http_message(events), to: HttpBinding.V_1_0.Encoder

  # ---

  @doc "Parses a Kafka message as a Cloudevent."
  @spec from_kafka_message(kafka_body, kafka_headers, options) ::
          {:ok, t()} | {:error, any}
  defdelegate from_kafka_message(kafka_body, kafka_headers, options \\ []),
    to: KafkaBinding.Decoder

  # ---

  @doc """
  Serialize an event in Kafka binary content mode.

  Binary mode basically means: the payload is in the body and the metadata is in the header.

      iex> event = Cloudevents.from_map!(%{
      ...>   specversion: "1.0",
      ...>   type: "some-type",
      ...>   source: "some-source",
      ...>   id: "1",
      ...>   data: %{"foo" => "bar"}})
      iex> {body, headers} = Cloudevents.to_kafka_binary_message(event)
      {
        "{\\"foo\\":\\"bar\\"}",
        [
          {"content-type", "application/json"},
          {"ce_specversion", "1.0"},
          {"ce_type", "some-type"},
          {"ce_source", "some-source"},
          {"ce_id", "1"}
        ]
      }

  """
  @spec to_kafka_binary_message(t()) :: {kafka_body, kafka_headers}
  defdelegate to_kafka_binary_message(event),
    to: KafkaBinding.V_1_0.Encoder,
    as: :to_binary_content_mode

  # ---

  @doc """
  Serialize an event in Kafka structured content mode.

  Structured mode basically means: the full event - payload and metadata - is in the body.

      iex> event = Cloudevents.from_map!(%{
      ...>   specversion: "1.0",
      ...>   type: "some-type",
      ...>   source: "some-source",
      ...>   id: "1",
      ...>   data: %{"foo" => "bar"}})
      iex> {body, headers} = Cloudevents.to_kafka_structured_message(event, :json)
      {
        "{\\"data\\":{\\"foo\\":\\"bar\\"},\\"datacontenttype\\":\\"application/json\\",\\"id\\":\\"1\\",\\"source\\":\\"some-source\\",\\"specversion\\":\\"1.0\\",\\"type\\":\\"some-type\\"}",
        [{"content-type", "application/cloudevents+json"}]
      }

  ## Avro

  By default, the Avro encoding contains the full event schema. If you're using the
  Confluent Schema Registry, you can set `confluent_schema_registry_url` via
  `options`. If set, instead the full schema only the schema ID is included in the
  output.
  """
  @spec to_kafka_structured_message(t(), event_format :: :json | :avro, options) ::
          {kafka_body, kafka_headers}
  defdelegate to_kafka_structured_message(event, event_format, options \\ []),
    to: KafkaBinding.V_1_0.Encoder,
    as: :to_structured_content_mode
end
