defprotocol Cloudevents.Format.Encoder.Avro do
  @moduledoc false

  @doc "Encodes a Cloudevent to an Avro binary."
  def encode(cloudevent)
end
