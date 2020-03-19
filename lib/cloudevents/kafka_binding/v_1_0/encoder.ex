defmodule Cloudevents.KafkaBinding.V_1_0.Encoder do
  @moduledoc false

  @spec to_binary_content_mode(Cloudevents.t()) ::
          {Cloudevents.kafka_body(), Cloudevents.kafka_headers()}
  def to_binary_content_mode(event) do
    body = Jason.encode!(event.data)

    headers =
      [
        {"content-type", "application/json"},
        {"ce_specversion", "1.0"},
        {"ce_type", event.type},
        {"ce_source", event.source},
        {"ce_id", event.id},
        {"ce_subject", event.subject},
        {"ce_time", event.time}
      ] ++ for {name, value} <- event.extensions, do: {"ce_#{name}", value}

    {body, headers}
  end

  # ---

  @spec to_structured_content_mode(Cloudevents.t(), :json | :avro, Cloudevents.options()) ::
          {Cloudevents.kafka_body(), Cloudevents.kafka_headers()}
  def to_structured_content_mode(event, event_format, opts)

  def to_structured_content_mode(event, :json, _opts) do
    body = Cloudevents.to_json(event)
    headers = [{"content-type", "application/cloudevents+json"}]
    {body, headers}
  end
end
