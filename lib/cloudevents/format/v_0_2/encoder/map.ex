defimpl Cloudevents.Format.Encoder.Map, for: Cloudevents.Format.V_0_2.Event do
  @moduledoc false

  alias Cloudevents.Format.V_0_2.Event

  def convert(%Event{specversion: "0.2", type: type, source: source, id: id} = event) do
    all_but_extensions =
      %{
        specversion: "0.2",
        type: type,
        source: source,
        id: id
      }
      |> add_if_set(event, :subject)
      |> add_if_set(event, :time)
      |> add_if_set(event, :datacontenttype)
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
