defimpl Cloudevents.Format.Encoder.JSON, for: Cloudevents.Format.V_0_2.Event do
  @moduledoc false

  def encode(event) do
    event
    |> Cloudevents.Format.Encoder.Map.convert()
    |> Jason.encode!()
  end
end
