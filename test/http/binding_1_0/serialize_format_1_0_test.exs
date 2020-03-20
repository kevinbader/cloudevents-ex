defmodule Cloudevents.Http.Binding_1_0.SerializeFormat_1_0_Test do
  @moduledoc false
  use ExUnit.Case
  doctest Cloudevents.HttpBinding.V_1_0.Decoder

  alias Cloudevents.Format.V_1_0.Event

  test "binary mode" do
    {:ok, event} =
      Event.from_map(%{
        "specversion" => "1.0",
        "type" => "a-type",
        "source" => "a-source",
        "id" => "1",
        "data" => %{
          "this" => "is the content"
        }
      })

    {body, headers} = Cloudevents.to_http_binary_message(event)
    assert Jason.decode(body) == {:ok, %{"this" => "is the content"}}
    assert {"content-type", "application/json"} in headers
    assert {"ce-specversion", "1.0"} in headers
    assert {"ce-type", "a-type"} in headers
    assert {"ce-source", "a-source"} in headers
    assert {"ce-id", "1"} in headers
  end

  test "binary mode with no data" do
    event =
      Cloudevents.from_map!(%{specversion: "1.0", type: "a-type", source: "a-source", id: "1"})

    {body, headers} = Cloudevents.to_http_binary_message(event)
    assert body == ""
    assert {"content-type", "application/json"} in headers
    assert {"ce-specversion", "1.0"} in headers
    assert {"ce-type", "a-type"} in headers
    assert {"ce-source", "a-source"} in headers
    assert {"ce-id", "1"} in headers
  end

  test "structured mode, JSON encoding" do
    {:ok, event} =
      Event.from_map(%{
        "specversion" => "1.0",
        "type" => "a-type",
        "source" => "a-source",
        "id" => "1",
        "data" => %{
          "this" => "is the content"
        }
      })

    {body, headers} = Cloudevents.to_http_structured_message(event, :json)
    {:ok, event_from_body} = Cloudevents.from_json(body)
    assert event_from_body.specversion == "1.0"
    assert event_from_body.type == event.type
    assert event_from_body.source == event.source
    assert event_from_body.id == event.id
    assert event_from_body.data == event.data
    assert {"content-type", "application/cloudevents+json"} in headers
  end

  # TODO: implement
  # test "batch encoding"
end
