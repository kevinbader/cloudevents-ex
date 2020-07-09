defmodule Cloudevents.Format.V_0_1.Decoder.JSON do
  @moduledoc false
  @behaviour Cloudevents.Format.Decoder.JSON

  alias Cloudevents.Format.Decoder.DecodeError
  alias Cloudevents.Format.ParseError
  alias Cloudevents.Format.V_0_1.Event

  @doc """
  Turns a JSON string into a Cloudevent 0.1 struct.

  ## Examples

  ### Successful case

      iex> json = ~S({
      ...>   "cloudEventsVersion": "0.1",
      ...>   "eventType": "com.github.pull.create",
      ...>   "source": "https://github.com/cloudevents/spec/pull",
      ...>   "eventID": "A234-1234-1234",
      ...>   "eventTime": "2018-04-05T17:31:00Z",
      ...>   "comexampleextension1": "value",
      ...>   "comexampleothervalue": 5,
      ...>   "contentType": "text/xml",
      ...>   "data": "<much wow=\\"xml\\"/>"
      ...> })
      iex> {:ok, event} = Cloudevents.Format.V_0_1.Decoder.JSON.decode(json)
      iex> with %Cloudevents.Format.V_0_1.Event{
      ...>   eventType: "com.github.pull.create",
      ...>   source: "https://github.com/cloudevents/spec/pull",
      ...>   eventID: "A234-1234-1234",
      ...>   eventTime: "2018-04-05T17:31:00Z",
      ...>   extensions: %{
      ...>     "comexampleextension1" => "value",
      ...>     "comexampleothervalue" => 5
      ...>   },
      ...>   contentType: "text/xml",
      ...>   data: ~S(<much wow="xml"/>)
      ...> } <- event, do: :passed
      :passed

  ### Not a JSON at all

      iex> not_a_json = "..."
      iex> Cloudevents.Format.V_0_1.Decoder.JSON.decode(not_a_json)
      {:error, %Cloudevents.Format.Decoder.DecodeError{
                cause: %Jason.DecodeError{data: "...", position: 0, token: nil}}}

  ### Missing required fields

      iex> json = ~S({
      ...>   "cloudEventsVersion": "0.1",
      ...>   "eventType": "com.github.pull.create"
      ...> })
      iex> Cloudevents.Format.V_0_1.Decoder.JSON.decode(json)
      {:error, %Cloudevents.Format.Decoder.DecodeError{
                cause: %Cloudevents.Format.ParseError{message: "missing source"}}}

  ### Invalid extension attribute name

      iex> json = ~S({
      ...>   "cloudEventsVersion": "0.1",
      ...>   "eventType": "com.github.pull.create",
      ...>   "source": "https://github.com/cloudevents/spec/pull",
      ...>   "eventID": "A234-1234-1234",
      ...>   "an extension attribute that contains spaces": "is not allowed"
      ...> })
      iex> Cloudevents.Format.V_0_1.Decoder.JSON.decode(json)
      {:error, %Cloudevents.Format.Decoder.DecodeError{
                cause: %Cloudevents.Format.ParseError{message: "invalid extension attributes: \\"an extension attribute that contains spaces\\""}}}

  """
  def decode(json) do
    with {:ok, orig_map} <- Jason.decode(json),
         {:ok, event} <- Event.from_map(orig_map) do
      data =
        if Map.has_key?(orig_map, "data_base64") do
          event.data
        else
          # If contenttype is application/json and data is a string, data could be an encoded JSON structure :/
          decode_json_if_possible(event.content_type, event.data)
        end

      event = Map.put(event, :data, data)
      {:ok, event}
    else
      {:error, %ParseError{} = error} -> {:error, %DecodeError{cause: error}}
      {:error, %Jason.DecodeError{} = error} -> {:error, %DecodeError{cause: error}}
    end
  end

  defp decode_json_if_possible(content_type, data) when byte_size(data) > 0 do
    # This is likely good enough but perhaps we should do proper mime type handling here..
    case content_type do
      "application/json" <> _ ->
        case Jason.decode(data) do
          {:ok, decoded} -> decoded
          _ -> data
        end

      _ ->
        data
    end
  end

  defp decode_json_if_possible(_, data), do: data
end
