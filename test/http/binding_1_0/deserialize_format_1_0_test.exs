defmodule Cloudevents.Http.Binding_1_0.DeserializeFormat_1_0_Test do
  @moduledoc false
  use ExUnit.Case
  doctest Cloudevents.HttpBinding.V_1_0.Decoder

  test "Payload in body, context attributes in the header" do
    body = "this is the content"

    headers = %{
      "content-type" => "text/plain",
      "ce-specversion" => "1.0",
      "ce-type" => "some-type",
      "ce-source" => "some-source",
      "ce-id" => "1"
    }

    assert {:ok, [event]} = Cloudevents.from_http_message(body, headers)
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
      "ce-specversion" => "1.0",
      "ce-type" => "com.example.test.simple",
      "ce-source" => "rig-test",
      "ce-id" => "069711bf-3946-4661-984f-c667657b8d85"
    }

    assert {:ok, [event]} = Cloudevents.from_http_message(body, headers)
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

    assert {:ok, [event]} = Cloudevents.from_http_message(body, headers)
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

    assert {:ok, [event]} = Cloudevents.from_http_message(body, headers)
    assert event.type == "some-type"
    assert event.source == "some-source"
    assert event.id == "1"
    assert event.datacontenttype == "application/json"
    assert event.data == %{"text" => "this is the content"}
  end

  # TODO: test is complete but implementation is missing
  # test "JSON encoded Cloudevents, batched together in a single body" do
  #   # Source: https://github.com/cloudevents/spec/blob/v1.0/http-protocol-binding.md#323-examples
  #   body = """
  #   [
  #     {
  #       "specversion": "1.0",
  #       "type": "com.example.someevent",
  #       "source": "abc",
  #       "id": "1",
  #       "data": {
  #         "text": "payload describing the first occurence"
  #       }
  #     },
  #     {
  #       "specversion": "1.0",
  #       "type": "com.example.someevent",
  #       "source": "abc",
  #       "id": "2",
  #       "data": {
  #         "text": "payload describing the second occurence"
  #       }
  #     }
  #   ]
  #   """

  #   headers = %{
  #     "content-type" => "application/cloudevents-batch+json; charset=UTF-8"
  #   }

  #   assert {:ok, [event1, event2]} = Cloudevents.from_http_message(body, headers)

  #   assert event1.id == "1"
  #   assert event1.datacontenttype == "application/json"
  #   assert event1.data == %{"text" => "payload describing the first occurence"}

  #   assert event2.id == "2"
  #   assert event2.datacontenttype == "application/json"
  #   assert event2.data == %{"text" => "payload describing the first occurence"}
  # end

  # TODO: test is complete but implementation is missing
  # test "An empty batch is considered an error." do
  #   body = """
  #   [
  #   ]
  #   """

  #   headers = %{
  #     "content-type" => "application/cloudevents-batch+json; charset=UTF-8"
  #   }

  #   assert {:error, _} = Cloudevents.from_http_message(body, headers)
  # end

  # TODO: test is complete but implementation is missing
  # test "Non-JSON batch is not supported." do
  #   body = """
  #   [
  #   ]
  #   """

  #   headers = %{
  #     "content-type" => "application/cloudevents-batch+avro; charset=UTF-8"
  #   }

  #   assert {:error, _} = Cloudevents.from_http_message(body, headers)
  # end
end
