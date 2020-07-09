defimpl Cloudevents.Format.Encoder.Map, for: Cloudevents.Format.V_0_1.Event do
  @moduledoc false

  alias Cloudevents.Format.V_0_1.Event

  def convert(
        %Event{
          cloudEventsVersion: "0.1",
          eventType: eventType,
          source: source,
          eventID: eventID
        } = event
      ) do
    all_but_extensions =
      %{
        cloudEventsVersion: "0.1",
        eventType: eventType,
        source: source,
        eventID: eventID
      }
      |> add_if_set(event, :subject)
      |> add_if_set(event, :eventTime)
      |> add_if_set(event, :contentType)
      |> add_if_set(event, :data)

    extensions = Map.get(event, :extensions, %{})

    # Extensions may never overwrite well-known context attributes:
    map = Map.merge(extensions, all_but_extensions)

    map
  end

  # ---

  defp add_if_set(dst, src, key) do
    val = Map.get(src, key)
    if val, do: Map.put(dst, key, val), else: dst
  end
end
