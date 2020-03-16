defmodule Cloudevents.Format.V_1_0.Encoder.JSONTest do
  @moduledoc false
  use ExUnit.Case

  alias Cloudevents.Format.Encoder.JSON, as: JsonEncoder
  alias Cloudevents.Format.V_1_0.Decoder.JSON, as: JsonDecoder

  test "There are no null values in a JSON-encoded Cloudevent." do
    {:ok, event} =
      JsonDecoder.decode("""
      {
        "specversion": "1.0",
        "type": "com.example.test",
        "source": "mysource",
        "id": "1"
      }
      """)

    json_encoded = JsonEncoder.encode(event)
    assert not String.contains?(json_encoded, "null")
  end
end
