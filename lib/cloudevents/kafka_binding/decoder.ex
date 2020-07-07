defmodule Cloudevents.KafkaBinding.Decoder do
  @moduledoc false

  alias Cloudevents.KafkaBinding.V_1_0

  @doc """
  Parses a Kafka message as a Cloudevent.

  The latest transport binding spec is used to parse the Kafka message. In case of a
  parsing error, older versions of the spec may be considered as a fallback.
  """
  @spec from_kafka_message(
          Cloudevents.kafka_body(),
          Cloudevents.kafka_headers()
        ) ::
          {:ok, Cloudevents.t()} | {:error, any}
  def from_kafka_message(kafka_body, kafka_headers) do
    with {:error, _} = error <- V_1_0.Decoder.from_kafka_message(kafka_body, kafka_headers) do
      error
    else
      {:ok, event} -> {:ok, event}
    end
  end
end
