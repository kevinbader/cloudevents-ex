defprotocol Cloudevents.Format.Encoder.JSON do
  @moduledoc false

  @doc "Encodes a Cloudevent to a JSON string."
  def encode(cloud_event)
end
