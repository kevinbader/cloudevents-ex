defmodule Cloudevents.Kafka.Binding_1_0.SerializeFormat_1_0_Test do
  @moduledoc false
  use ExUnit.Case
  doctest Cloudevents.KafkaBinding.V_1_0.Decoder

  alias Cloudevents.Format.V_1_0.Event

  test "binary mode" do
    {:ok, event} =
      Event.from_map(%{
        "specversion" => "1.0",
        "type" => "some-type",
        "source" => "some-source",
        "id" => "1",
        "data" => %{
          "this" => "is the content"
        }
      })

    {body, headers} = Cloudevents.to_kafka_binary_message(event)
    assert Jason.decode(body) == {:ok, %{"this" => "is the content"}}
    assert {"content-type", "application/json"} in headers
    assert {"ce_specversion", "1.0"} in headers
    assert {"ce_type", "some-type"} in headers
    assert {"ce_source", "some-source"} in headers
    assert {"ce_id", "1"} in headers
  end

  test "structured mode, JSON encoding" do
    {:ok, event} =
      Event.from_map(%{
        "specversion" => "1.0",
        "type" => "some-type",
        "source" => "some-source",
        "id" => "1",
        "data" => %{
          "this" => "is the content"
        }
      })

    {body, headers} = Cloudevents.to_kafka_structured_message(event, :json)
    {:ok, event_from_body} = Cloudevents.from_json(body)
    assert event_from_body.specversion == "1.0"
    assert event_from_body.type == event.type
    assert event_from_body.source == event.source
    assert event_from_body.id == event.id
    assert event_from_body.data == event.data
    assert {"content-type", "application/cloudevents+json"} in headers
  end
end
