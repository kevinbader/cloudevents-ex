defmodule Cloudevents.Kafka.Binding_1_0.DeserializeFormat_1_0_Test do
  @moduledoc false
  use ExUnit.Case
  doctest Cloudevents.KafkaBinding.V_1_0.Decoder

  test "Payload in body, context attributes in the header" do
    body = "this is the content"

    headers = %{
      "content-type" => "text/plain",
      "ce_specversion" => "1.0",
      "ce_type" => "some-type",
      "ce_source" => "some-source",
      "ce_id" => "1"
    }

    assert {:ok, [event]} = Cloudevents.from_kafka_message(body, headers)
    assert event.type == "some-type"
    assert event.source == "some-source"
    assert event.id == "1"
    assert event.datacontenttype == "text/plain"
    assert event.data == "this is the content"
  end

  test "With Content-Type of cloudevent, JSON encoding is the default" do
    body = """
    {
      "specversion": "1.0",
      "type": "some-type",
      "source": "some-source",
      "id": "1"
    }
    """

    headers = %{
      "content-type" => "application/cloudevents"
    }

    assert {:ok, [event]} = Cloudevents.from_kafka_message(body, headers)
    assert event.type == "some-type"
    assert event.source == "some-source"
    assert event.id == "1"
  end

  test "JSON encoded Cloudevent, with nested data, in the body" do
    body = """
    {
      "specversion": "1.0",
      "type": "some-type",
      "source": "some-source",
      "id": "1",
      "data": {
        "text": "this is the content"
      }
    }
    """

    headers = %{
      "content-type" => "application/cloudevents+json"
    }

    assert {:ok, [event]} = Cloudevents.from_kafka_message(body, headers)
    assert event.type == "some-type"
    assert event.source == "some-source"
    assert event.id == "1"
    assert event.datacontenttype == "application/json"
    assert event.data == %{"text" => "this is the content"}
  end
end
