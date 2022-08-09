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
  @external_resource "README.md"
  @moduledoc File.read!("README.md")

  alias Cloudevents.Format
  alias Cloudevents.HttpBinding

  alias Cloudevents.KafkaBinding

  @typedoc "Cloudevent"
  @type t :: Format.V_1_0.Event.t() | Format.V_0_2.Event.t() | Format.V_0_1.Event.t()

  @typedoc "Configuration parameters for encoding and decoding of data"
  @type options :: [option]

  @typedoc "Configuration parameter"
  @type option ::
          {:confluent_schema_registry_url, confluent_schema_registry_url}
          | {:avro_schemas_path, avro_schemas_path}
          | {:avro_cache_ttl, avro_cache_ttl}
          | {:avro_event_schema_name, avro_event_schema_name}

  @typedoc "Confluent Schema Registry URL for resolving Avro schemas by ID"
  @type confluent_schema_registry_url :: String.t()

  @typedoc "Base path for locally stored schema files (default `./priv/schemas`)"
  @type avro_schemas_path :: String.t()

  @typedoc "Time in ms to cache Avro schemas in memory (default `300_000`)"
  @type avro_cache_ttl :: non_neg_integer()

  @typedoc "Name of the Avro-schema used to encode events"
  @type avro_event_schema_name :: String.t()

  @typedoc "HTTP body"
  @type http_body :: binary()

  @typedoc "HTTP headers"
  @type http_headers :: [{String.t(), String.t()}]

  @typedoc "Kafka body"
  @type kafka_body :: binary()

  @typedoc "Kafka headers"
  @type kafka_headers :: [{String.t(), String.t()}]

  use Supervisor

  @doc """
  Runs the `cloudevents` supervisor; needed for Avro support and its schema caching.
  """
  @spec start_link(options) :: {:ok, pid} | {:error, any}
  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  Stops the `cloudevents` supervisor.
  """
  def stop do
    Supervisor.stop(__MODULE__)
  end

  @impl Supervisor
  def init(opts) do
    # e.g. http://localhost:8081, default to http://, so it's more user friendly
    registry_url =
      opts |> Keyword.get(:confluent_schema_registry_url) |> registry_url_with_http_schema()

    Application.put_env(:avrora, :registry_url, registry_url, persistent: true)

    schemas_path = Keyword.get(opts, :avro_schemas_path, Path.expand("./priv/schemas"))
    Application.put_env(:avrora, :schemas_path, schemas_path, persistent: true)

    names_cache_ttl = Keyword.get(opts, :avro_cache_ttl, :timer.minutes(5))
    Application.put_env(:avrora, :names_cache_ttl, names_cache_ttl, persistent: true)

    children = [
      Avrora,
      {Cloudevents.Config, opts}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end

  def handle_call(:avro_event_schema_name, _from, state) do
    reply =
      case Keyword.get(state, :avro_event_schema_name) do
        nil -> {:error, :unset}
        schema -> {:ok, schema}
      end

    {:ok, reply}
  end

  # ---

  defp registry_url_with_http_schema("http://" <> _registry_host = registry_url), do: registry_url

  defp registry_url_with_http_schema("https://" <> _registry_host = registry_url),
    do: registry_url

  defp registry_url_with_http_schema(registry_url) when is_binary(registry_url),
    do: "http://" <> registry_url

  defp registry_url_with_http_schema(nil), do: nil

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
          {:ok, t()} | {:error, %Cloudevents.Format.ParseError{}}
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

  @doc "Encodes a Cloudevent using JSON format."
  @spec to_json(t()) :: binary()
  defdelegate to_json(cloudevent), to: Format.Encoder.JSON, as: :encode

  # ---

  @doc """
  Decodes an Avro-encoded Cloudevent (requires `Cloudevents.start_link/1`).

  TODO: tests/examples
  """
  @spec from_avro(avro :: binary(), ctx_attrs :: map) ::
          {:ok, t()} | {:error, %Cloudevents.Format.Decoder.DecodeError{}}
  defdelegate from_avro(avro, ctx_attrs), to: Format.Decoder.Avro, as: :decode

  # ---

  @doc """
  Encodes a Cloudevent using Avro binary encoding (requires `Cloudevents.start_link/1`).

  TODO: tests/examples
  """
  @spec to_avro(t()) :: {:ok, binary()} | {:error, term()}
  defdelegate to_avro(avro), to: Format.Encoder.Avro, as: :encode

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
  @spec from_http_message(http_body, http_headers) ::
          {:ok, [t()]} | {:error, any}
  defdelegate from_http_message(http_body, http_headers), to: HttpBinding.Decoder

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
      iex> {_body, _headers} = Cloudevents.to_http_binary_message(event)
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
  @spec to_http_structured_message(t(), event_format :: :json | :avro_binary) ::
          {:ok, {http_body, http_headers}}
  defdelegate to_http_structured_message(event, event_format),
    to: HttpBinding.V_1_0.Encoder,
    as: :to_structured_content_mode

  # ---

  # @doc "Serialize one or more events in HTTP batched content mode."
  # @spec to_batched_http_message([t()]) :: {http_body, http_headers}
  # defdelegate to_batched_http_message(events), to: HttpBinding.V_1_0.Encoder

  # ---

  @doc "Parses a Kafka message as a Cloudevent."
  @spec from_kafka_message(kafka_body, kafka_headers) ::
          {:ok, t()} | {:error, any}
  defdelegate from_kafka_message(kafka_body, kafka_headers),
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
      iex> {_body, _headers} = Cloudevents.to_kafka_binary_message(event)
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
      iex> {:ok, {body, headers}} = Cloudevents.to_kafka_structured_message(event, :json)
      iex> {body, headers}
      {
        "{\\"data\\":{\\"foo\\":\\"bar\\"},\\"datacontenttype\\":\\"application/json\\",\\"id\\":\\"1\\",\\"source\\":\\"some-source\\",\\"specversion\\":\\"1.0\\",\\"type\\":\\"some-type\\"}",
        [{"content-type", "application/cloudevents+json"}]
      }

  Note that Avro encoding requires a preceding call to `Cloudevents.start_link/1`.
  """
  @spec to_kafka_structured_message(t(), event_format :: :json | :avro_binary) ::
          {:ok, {kafka_body, kafka_headers}} | {:error, term}
  defdelegate to_kafka_structured_message(event, event_format),
    to: KafkaBinding.V_1_0.Encoder,
    as: :to_structured_content_mode
end
