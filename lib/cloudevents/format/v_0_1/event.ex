defmodule Cloudevents.Format.V_0_1.Event do
  @desc "Cloudevents format v0.1."
  @moduledoc @desc
  use TypedStruct
  alias Cloudevents.Format.ParseError

  # %Cloudevents.Format.V_0_1.Event{
  #   cloudEventsVersion: "0.1",
  #   contentType: "application/json",
  #   data: %{"foo" => "avro required"},
  #   eventID: "1",
  #   eventTime: nil,
  #   eventType: "rig.avro.test1",
  #   extensions: %{},
  #   schemaURL: nil,
  #   source: "/test-producer"
  # }

  @typedoc @desc
  typedstruct do
    field(:cloudEventsVersion, String.t(), default: "0.1")
    field(:eventType, String.t(), enforce: true)
    field(:source, String.t(), enforce: true)
    field(:eventID, String.t(), enforce: true)
    field(:eventTime, String.t())
    field(:contentType, String.t())
    field(:schemaURL, String.t())
    field(:data, any)
    field(:extensions, %{optional(String.t()) => any})
  end

  def from_map(map) when is_map(map) do
    # Cloudevents carry the actual payload in the "data" field. The other fields are
    # called "context attributes" (abbreviated `ctx_attrs` here). Extensions are all
    # context attributes that are not well-known, i.e., defined in the spec. They are
    # context attributes as well but also called "extension attributes".
    {event_data, ctx_attrs} = Map.pop(map, "data")

    {_, extension_attrs} =
      Map.split(ctx_attrs, [
        "cloudEventsVersion",
        "eventType",
        "source",
        "eventID",
        "eventTime",
        "contentType",
        "schemaURL",
        "data"
      ])

    with :ok <- parse_specversion(ctx_attrs),
         {:ok, eventType} <- parse_type(ctx_attrs),
         {:ok, source} <- parse_source(ctx_attrs),
         {:ok, eventID} <- parse_id(ctx_attrs),
         {:ok, eventTime} <- parse_time(ctx_attrs),
         {:ok, contentType} <- parse_contenttype(ctx_attrs),
         {:ok, schemaURL} <- parse_schemaurl(ctx_attrs),
         {:ok, data} <- parse_data(event_data),
         {:ok, extensions} <- validated_extensions_attributes(extension_attrs) do
      contentType =
        if is_nil(contentType) and not is_nil(data),
          do: "application/json",
          else: contentType

      event = %__MODULE__{
        eventType: eventType,
        source: source,
        eventID: eventID,
        eventTime: eventTime,
        contentType: contentType,
        schemaURL: schemaURL,
        data: data,
        extensions: extensions
      }

      {:ok, event}
    else
      {:error, parse_error} ->
        {:error, %ParseError{message: parse_error}}
    end
  end

  # ---

  defp parse_specversion(%{"cloudEventsVersion" => "0.1"}), do: :ok

  defp parse_specversion(%{"cloudEventsVersion" => x}),
    do: {:error, "unexpected cloudEventsVersion #{x}"}

  defp parse_specversion(_), do: {:error, "missing cloudEventsVersion"}

  defp parse_type(%{"eventType" => type}) when byte_size(type) > 0, do: {:ok, type}
  defp parse_type(_), do: {:error, "missing eventType"}

  defp parse_source(%{"source" => source}) when byte_size(source) > 0, do: {:ok, source}
  defp parse_source(_), do: {:error, "missing source"}

  defp parse_id(%{"eventID" => id}) when byte_size(id) > 0, do: {:ok, id}
  defp parse_id(_), do: {:error, "missing eventID"}

  defp parse_time(%{"eventTime" => time}) when byte_size(time) > 0, do: {:ok, time}
  defp parse_time(%{"eventTime" => ""}), do: {:error, "eventTime given but empty"}
  defp parse_time(_), do: {:ok, nil}

  defp parse_contenttype(%{"contentType" => ct}) when byte_size(ct) > 0, do: {:ok, ct}

  defp parse_contenttype(%{"contentType" => ""}),
    do: {:error, "contentType given but empty"}

  defp parse_contenttype(_), do: {:ok, nil}

  defp parse_schemaurl(%{"schemaURL" => schema}) when byte_size(schema) > 0, do: {:ok, schema}

  defp parse_schemaurl(%{"schemaURL" => ""}),
    do: {:error, "schemaURL given but empty"}

  defp parse_schemaurl(_), do: {:ok, nil}

  defp parse_data(""), do: {:error, "data field given but empty"}
  defp parse_data(data), do: {:ok, data}

  # ---

  defp try_decode(key, val) when is_binary(val) do
    case Jason.decode(val) do
      {:ok, val_map} ->
        {key, val_map}

      _ ->
        {key, val}
    end
  end

  defp try_decode(key, val), do: {key, val}

  # ---

  defp validated_extensions_attributes(extension_attrs) do
    invalid =
      extension_attrs
      |> Map.keys()
      |> Enum.map(fn key -> {key, valid_extension_attribute_name(key)} end)
      |> Enum.filter(fn {_, valid?} -> not valid? end)

    case invalid do
      [] ->
        extensions = Map.new(extension_attrs, fn {key, val} -> try_decode(key, val) end)
        {:ok, extensions}

      _ ->
        {:error,
         "invalid extension attributes: #{Enum.map(invalid, fn {key, _} -> inspect(key) end)}"}
    end
  end

  # ---

  defp valid_extension_attribute_name(name) do
    # Cloudevents attribute names MUST consist of lower-case letters ('a' to 'z') or
    # digits ('0' to '9') from the ASCII character set. Attribute names SHOULD be
    # descriptive and terse and SHOULD NOT exceed 20 characters in length.
    # https://github.com/cloudevents/spec/blob/v1.0/spec.md#attribute-naming-convention
    name =~ ~r/^[a-z0-9]+$/
  end
end
