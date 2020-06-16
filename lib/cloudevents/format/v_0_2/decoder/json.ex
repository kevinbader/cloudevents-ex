defmodule Cloudevents.Format.V_0_2.Decoder.JSON do
  @moduledoc false
  @behaviour Cloudevents.Format.Decoder.JSON

  alias Cloudevents.Format.Decoder.DecodeError
  alias Cloudevents.Format.ParseError
  alias Cloudevents.Format.V_0_2.Event

  @doc """
  Turns a JSON string into a Cloudevent 0.2 struct.

  ## Examples

  ### Successful case

      iex> json = ~S({
      ...>   "specversion": "0.2",
      ...>   "type": "com.github.pull.create",
      ...>   "source": "https://github.com/cloudevents/spec/pull",
      ...>   "id": "A234-1234-1234",
      ...>   "time": "2018-04-05T17:31:00Z",
      ...>   "comexampleextension1": "value",
      ...>   "comexampleothervalue": 5,
      ...>   "contenttype": "text/xml",
      ...>   "data": "<much wow=\\"xml\\"/>"
      ...> })
      iex> {:ok, event} = Cloudevents.Format.V_0_2.Decoder.JSON.decode(json)
      iex> with %Cloudevents.Format.V_0_2.Event{
      ...>   type: "com.github.pull.create",
      ...>   source: "https://github.com/cloudevents/spec/pull",
      ...>   id: "A234-1234-1234",
      ...>   time: "2018-04-05T17:31:00Z",
      ...>   extensions: %{
      ...>     "comexampleextension1" => "value",
      ...>     "comexampleothervalue" => 5
      ...>   },
      ...>   contenttype: "text/xml",
      ...>   data: ~S(<much wow="xml"/>)
      ...> } <- event, do: :passed
      :passed

  ### Not a JSON at all

      iex> not_a_json = "..."
      iex> Cloudevents.Format.V_0_2.Decoder.JSON.decode(not_a_json)
      {:error, %Cloudevents.Format.Decoder.DecodeError{
                cause: %Jason.DecodeError{data: "...", position: 0, token: nil}}}

  ### Missing required fields

      iex> json = ~S({
      ...>   "specversion": "0.2",
      ...>   "type": "com.github.pull.create"
      ...> })
      iex> Cloudevents.Format.V_0_2.Decoder.JSON.decode(json)
      {:error, %Cloudevents.Format.Decoder.DecodeError{
                cause: %Cloudevents.Format.ParseError{message: "missing source"}}}

  ### Invalid extension attribute name

      iex> json = ~S({
      ...>   "specversion": "0.2",
      ...>   "type": "com.github.pull.create",
      ...>   "source": "https://github.com/cloudevents/spec/pull",
      ...>   "id": "A234-1234-1234",
      ...>   "an extension attribute that contains spaces": "is not allowed"
      ...> })
      iex> Cloudevents.Format.V_0_2.Decoder.JSON.decode(json)
      {:error, %Cloudevents.Format.Decoder.DecodeError{
                cause: %Cloudevents.Format.ParseError{message: "invalid extension attributes: \\"an extension attribute that contains spaces\\""}}}

  """
  def decode(json) do
    with {:ok, orig_map} <- Jason.decode(json),
         preprocessed_map = handle_data_base64(orig_map),
         {:ok, event} <- Event.from_map(preprocessed_map) do
      # `data_base64` may only be used for binary data, so we only try to interpret
      # `data` as JSON if `data_base64` isn't present:
      data =
        if Map.has_key?(orig_map, "data_base64") do
          event.data
        else
          # If contenttype is application/json and data is a string, data could be an encoded JSON structure :/
          decode_json_if_possible(event.contenttype, event.data)
        end

      event = Map.put(event, :data, data)
      {:ok, event}
    else
      {:error, %ParseError{} = error} -> {:error, %DecodeError{cause: error}}
      {:error, %Jason.DecodeError{} = error} -> {:error, %DecodeError{cause: error}}
    end
  end

  # ---

  defp handle_data_base64(map)

  defp handle_data_base64(%{"data_base64" => encoded} = map) do
    decoded = :base64.decode(encoded)

    map
    |> Map.delete("data_base64")
    |> Map.put("data", decoded)
  end

  defp handle_data_base64(map), do: map

  # ---

  defp decode_json_if_possible(contenttype, data) when byte_size(data) > 0 do
    # This is likely good enough but perhaps we should do proper mime type handling here..
    case contenttype do
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
