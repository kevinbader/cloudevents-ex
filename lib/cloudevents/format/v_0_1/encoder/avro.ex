defimpl Cloudevents.Format.Encoder.Avro, for: Cloudevents.Format.V_0_1.Event do
  @moduledoc false

  def encode(event) do
    case Cloudevents.Config.avro_event_schema_name() do
      nil ->
        {:error, "The name of the Avro-schema used to encode events is not set"}

      schema_name ->
        event
        |> Cloudevents.Format.Encoder.Map.convert()
        |> Avrora.encode(schema_name: schema_name)
    end
  end
end
