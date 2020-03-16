defmodule Cloudevents.HttpBinding.V_1_0.Encoder do
  @moduledoc false

  def to_binary_http_message(event) do
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

  def to_structured_http_message(event, event_format)

  def to_structured_http_message(event, :json) do
    body = Cloudevents.to_json(event)
    headers = [{"content-type", "application/cloudevents+json"}]
    {body, headers}
  end

  # ---

  def to_batched_http_message(_events) do
    # TODO
    raise "Not implemented."
  end
end
