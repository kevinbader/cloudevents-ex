defprotocol Cloudevents.Format.Encoder.Map do
  @moduledoc false

  @doc "Converts a Cloudevent into an Elixir map."
  def convert(cloudevent)
end
