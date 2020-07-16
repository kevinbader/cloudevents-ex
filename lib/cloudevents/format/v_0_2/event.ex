defmodule Cloudevents.Format.V_0_2.Event do
  @desc "Cloudevents format v0.2."
  @moduledoc @desc
  use TypedStruct
  alias Cloudevents.Format.ParseError

  @typedoc @desc
  typedstruct do
    field(:specversion, String.t(), default: "0.2")
    field(:type, String.t(), enforce: true)
    field(:source, String.t(), enforce: true)
    field(:id, String.t(), enforce: true)
    field(:time, String.t())
    field(:schemaurl, String.t())
    field(:contenttype, String.t())
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
        "specversion",
        "type",
        "source",
        "id",
        "time",
        "contenttype",
        "schemaurl",
        "data"
      ])

    with :ok <- parse_specversion(ctx_attrs),
         {:ok, type} <- parse_type(ctx_attrs),
         {:ok, source} <- parse_source(ctx_attrs),
         {:ok, id} <- parse_id(ctx_attrs),
         {:ok, time} <- parse_time(ctx_attrs),
         {:ok, contenttype} <- parse_contenttype(ctx_attrs),
         {:ok, schemaurl} <- parse_schemaurl(ctx_attrs),
         {:ok, data} <- parse_data(event_data),
         {:ok, extensions} <- validated_extensions_attributes(extension_attrs) do
      contenttype =
        if is_nil(contenttype) and not is_nil(data),
          do: "application/json",
          else: contenttype

      event = %__MODULE__{
        type: type,
        source: source,
        id: id,
        time: time,
        contenttype: contenttype,
        schemaurl: schemaurl,
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

  defp parse_specversion(%{"specversion" => "0.2"}), do: :ok
  defp parse_specversion(%{"specversion" => x}), do: {:error, "unexpected specversion #{x}"}
  defp parse_specversion(_), do: {:error, "missing specversion"}

  defp parse_type(%{"type" => type}) when byte_size(type) > 0, do: {:ok, type}
  defp parse_type(_), do: {:error, "missing type"}

  defp parse_source(%{"source" => source}) when byte_size(source) > 0, do: {:ok, source}
  defp parse_source(_), do: {:error, "missing source"}

  defp parse_id(%{"id" => id}) when byte_size(id) > 0, do: {:ok, id}
  defp parse_id(_), do: {:error, "missing id"}

  defp parse_time(%{"time" => time}) when byte_size(time) > 0, do: {:ok, time}
  defp parse_time(%{"time" => ""}), do: {:error, "time given but empty"}
  defp parse_time(_), do: {:ok, nil}

  defp parse_contenttype(%{"contenttype" => ct}) when byte_size(ct) > 0, do: {:ok, ct}

  defp parse_contenttype(%{"contenttype" => ""}),
    do: {:error, "contenttype given but empty"}

  defp parse_contenttype(_), do: {:ok, nil}

  defp parse_schemaurl(%{"schemaurl" => schema}) when byte_size(schema) > 0, do: {:ok, schema}

  defp parse_schemaurl(%{"schemaurl" => ""}),
    do: {:error, "schemaurl given but empty"}

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
