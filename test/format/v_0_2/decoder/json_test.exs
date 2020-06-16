defmodule Cloudevents.Format.V_0_2.Decoder.JSONTest do
  @moduledoc false
  use ExUnit.Case
  doctest Cloudevents.Format.V_0_2.Decoder.JSON

  alias Cloudevents.Format.V_0_2.Decoder.JSON

  test "specversion, type, source and id are the required fields." do
    {:error, _} =
      JSON.decode("""
          {
            "specversion": "0.2",
            "type": "com.example.test",
            "source": "mysource"
          }
      """)

    {:ok, _} =
      JSON.decode("""
          {
            "specversion": "0.2",
            "type": "com.example.test",
            "source": "mysource",
            "id": "1"
          }
      """)
  end
end
