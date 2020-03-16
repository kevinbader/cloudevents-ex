defmodule Cloudevents.Format.V_1_0.EventTest do
  @moduledoc false
  use ExUnit.Case

  alias Cloudevents.Format.V_1_0.Event

  test "The datacontenttype defaults to JSON if data is given." do
    # If data is present, datacontenttype is, too:
    assert {:ok, %Event{datacontenttype: "application/json"}} =
             Event.from_map(%{
               "specversion" => "1.0",
               "type" => "com.example.test",
               "source" => "mysource",
               "id" => "1",
               "data" => "data is a string, which is okay"
             })

    # If data is not present, datacontenttype is nil:
    assert {:ok, %Event{datacontenttype: nil}} =
             Event.from_map(%{
               "specversion" => "1.0",
               "type" => "com.example.test",
               "source" => "mysource",
               "id" => "1"
             })
  end
end
