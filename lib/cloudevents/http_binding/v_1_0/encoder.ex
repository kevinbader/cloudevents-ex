defmodule Cloudevents.HttpBinding.V_1_0.Encoder do
  @moduledoc false

  @spec to_binary_content_mode(Cloudevents.t()) ::
          {Cloudevents.http_body(), Cloudevents.http_headers()}
  def to_binary_content_mode(event) do
    body = Jason.encode!(event.data)

    headers =
      [
        {"content-type", "application/json"},
        {"ce-specversion", "1.0"},
        {"ce-type", event.type},
        {"ce-source", event.source},
        {"ce-id", event.id},
        {"ce-subject", event.subject},
        {"ce-time", event.time}
      ] ++ for {name, value} <- event.extensions, do: {"ce-#{name}", value}

    {body, headers}
  end

  # ---

  @spec to_structured_content_mode(Cloudevents.t(), :json | :avro, Cloudevents.options()) ::
          {Cloudevents.http_body(), Cloudevents.http_headers()}
  def to_structured_content_mode(event, event_format, opts)

  def to_structured_content_mode(event, :json, _opts) do
    body = Cloudevents.to_json(event)
    headers = [{"content-type", "application/cloudevents+json"}]
    {body, headers}
  end

  # ---

  def to_batched_content_mode(_events) do
    # TODO
    raise "Not implemented."
  end
end
