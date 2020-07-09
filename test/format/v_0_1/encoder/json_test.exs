defmodule Cloudevents.Format.V_0_1.Encoder.JSONTest do
  @moduledoc false
  use ExUnit.Case

  alias Cloudevents.Format.Encoder.JSON, as: JsonEncoder
  alias Cloudevents.Format.V_0_1.Decoder.JSON, as: JsonDecoder

  test "There are no null values in a JSON-encoded Cloudevent." do
    {:ok, event} =
      JsonDecoder.decode("""
      {
        "cloudEventsVersion": "0.1",
        "eventType": "com.example.test",
        "source": "mysource",
        "eventID": "1"
      }
      """)

    json_encoded = JsonEncoder.encode(event)
    assert not String.contains?(json_encoded, "null")
  end
end
