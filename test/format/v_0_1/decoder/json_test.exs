defmodule Cloudevents.Format.V_0_1.Decoder.JSONTest do
  @moduledoc false
  use ExUnit.Case
  doctest Cloudevents.Format.V_0_1.Decoder.JSON

  alias Cloudevents.Format.V_0_1.Decoder.JSON

  test "cloudEventsVersion, eventType, source and eventID are the required fields." do
    {:error, _} =
      JSON.decode("""
          {
            "cloudEventsVersion": "0.1",
            "eventType": "com.example.test",
            "source": "mysource"
          }
      """)

    {:ok, _} =
      JSON.decode("""
          {
            "cloudEventsVersion": "0.1",
            "eventType": "com.example.test",
            "source": "mysource",
            "eventID": "1"
          }
      """)
  end
end
