defmodule Cloudevents.Format.V_0_2.Encoder.JSONTest do
  @moduledoc false
  use ExUnit.Case

  alias Cloudevents.Format.Encoder.JSON, as: JsonEncoder
  alias Cloudevents.Format.V_0_2.Decoder.JSON, as: JsonDecoder

  test "There are no null values in a JSON-encoded Cloudevent." do
    {:ok, event} =
      JsonDecoder.decode("""
      {
        "specversion": "0.2",
        "type": "com.example.test",
        "source": "mysource",
        "id": "1"
      }
      """)

    json_encoded = JsonEncoder.encode(event)
    assert not String.contains?(json_encoded, "null")
  end
end
