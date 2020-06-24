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

    assert {:ok, event} = Cloudevents.from_kafka_message(body, headers)
    assert event.type == "some-type"
    assert event.source == "some-source"
    assert event.id == "1"
    assert event.datacontenttype == "text/plain"
    assert event.data == "this is the content"
  end

  test "A JSON payload in the body is decoded" do
    body = """
    {
      "foo": "bar"
    }
    """

    headers = %{
      "content-type" => "application/json",
      "ce_specversion" => "1.0",
      "ce_type" => "com.example.test.simple",
      "ce_source" => "rig-test",
      "ce_id" => "069711bf-3946-4661-984f-c667657b8d85"
    }

    assert {:ok, event} = Cloudevents.from_kafka_message(body, headers)
    assert event.datacontenttype == "application/json"
    assert event.data == %{"foo" => "bar"}
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

    assert {:ok, event} = Cloudevents.from_kafka_message(body, headers)
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

    assert {:ok, event} = Cloudevents.from_kafka_message(body, headers)
    assert event.type == "some-type"
    assert event.source == "some-source"
    assert event.id == "1"
    assert event.datacontenttype == "application/json"
    assert event.data == %{"text" => "this is the content"}
  end
end
