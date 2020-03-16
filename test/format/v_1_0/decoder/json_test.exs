defmodule Cloudevents.Format.V_1_0.Decoder.JSONTest do
  @moduledoc false
  use ExUnit.Case
  doctest Cloudevents.Format.V_1_0.Decoder.JSON

  alias Cloudevents.Format.V_1_0.Decoder.JSON
  alias Cloudevents.Format.V_1_0.Event

  describe "event format JSON, datacontenttype is application/json:" do
    test "If data is not a string, it is a nested JSON Object." do
      {:ok, _} =
        JSON.decode("""
        {
          "specversion": "1.0",
          "type": "com.example.test",
          "source": "mysource",
          "id": "1",
          "datacontenttype": "application/json",
          "data": "data is a string, which is okay"
        }
        """)

      {:ok, _} =
        JSON.decode("""
        {
          "specversion": "1.0",
          "type": "com.example.test",
          "source": "mysource",
          "id": "1",
          "datacontenttype": "application/json",
          "data": {
            "data is a JSON object": "which is also okay"
          }
        }
        """)

      # We don't explicitly deny other types for `data` - we're tolerant :)
    end

    test "If data is a string and can be interpreted as encoded JSON, it _is_ encoded JSON." do
      {:ok, %Event{data: data}} =
        JSON.decode("""
        {
          "specversion": "1.0",
          "type": "com.example.test",
          "source": "mysource",
          "id": "1",
          "datacontenttype": "application/json",
          "data": "{\\"hey look\\": \\"there is a JSON object in there\\"}"
        }
        """)

      assert data == %{"hey look" => "there is a JSON object in there"}
    end

    test "If data is a string and can be interpreted as JSON, but datacontenttype is not JSON, it isn't interpreted as JSON." do
      {:ok, %Event{data: data}} =
        JSON.decode("""
        {
          "specversion": "1.0",
          "type": "com.example.test",
          "source": "mysource",
          "id": "1",
          "datacontenttype": "text/plain",
          "data": "{\\"hey look\\": \\"there is a JSON object in there\\"}"
        }
        """)

      assert data == ~S({"hey look": "there is a JSON object in there"})
    end

    test "If data is a string and cannot be interpreted as encoded JSON, it is an ordinary string." do
      {:ok, %Event{data: data}} =
        JSON.decode("""
        {
          "specversion": "1.0",
          "type": "com.example.test",
          "source": "mysource",
          "id": "1",
          "datacontenttype": "application/json",
          "data": "{ { }"
        }
        """)

      assert data == "{ { }"
    end

    # https://github.com/cloudevents/spec/blob/v1.0/json-format.md#31-handling-of-data
    test "If data_base64 is present, it's Base64-decoded and the result is always interpreted as a string (so no JSON decoding is attempted)." do
      # encoding of: {"hey look": "there is a JSON object in there"}
      base64_encoded = "eyJoZXkgbG9vayI6ICJ0aGVyZSBpcyBhIEpTT04gb2JqZWN0IGluIHRoZXJlIn0="

      {:ok, %Event{data: data}} =
        JSON.decode("""
        {
          "specversion": "1.0",
          "type": "com.example.test",
          "source": "mysource",
          "id": "1",
          "datacontenttype": "application/json",
          "data_base64": "#{base64_encoded}"
        }
        """)

      # data should be a string and _not_ be interpreted as JSON - data_base64 is ought to be used for binary data only.
      assert data == ~S({"hey look": "there is a JSON object in there"})
    end
  end

  # datacontenttype defaults to application/json
  describe "event format JSON, datacontenttype not set:" do
    test "If data is not a string, it is a nested JSON Object." do
      {:ok, _} =
        JSON.decode("""
        {
          "specversion": "1.0",
          "type": "com.example.test",
          "source": "mysource",
          "id": "1",
          "data": "data is a string, which is okay"
        }
        """)

      {:ok, _} =
        JSON.decode("""
        {
          "specversion": "1.0",
          "type": "com.example.test",
          "source": "mysource",
          "id": "1",
          "data": {
            "data is a JSON object": "which is also okay"
          }
        }
        """)

      # We don't explicitly deny other types for `data` - we're tolerant :)
    end

    test "If data is a string and can be interpreted as encoded JSON, it _is_ encoded JSON." do
      {:ok, %Event{data: data}} =
        JSON.decode("""
        {
          "specversion": "1.0",
          "type": "com.example.test",
          "source": "mysource",
          "id": "1",
          "data": "{\\"hey look\\": \\"there is a JSON object in there\\"}"
        }
        """)

      assert data == %{"hey look" => "there is a JSON object in there"}
    end

    test "If data is a string and cannot be interpreted as encoded JSON, it is an ordinary string." do
      {:ok, %Event{data: data}} =
        JSON.decode("""
        {
          "specversion": "1.0",
          "type": "com.example.test",
          "source": "mysource",
          "id": "1",
          "data": "{ { }"
        }
        """)

      assert data == "{ { }"
    end
  end
end
