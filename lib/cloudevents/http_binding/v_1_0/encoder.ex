defmodule Cloudevents.HttpBinding.V_1_0.Encoder do
  @moduledoc false

  @spec to_binary_content_mode(Cloudevents.t()) ::
          {Cloudevents.http_body(), Cloudevents.http_headers()}
  def to_binary_content_mode(event) do
    body =
      case event.data do
        nil -> ""
        data -> Jason.encode!(data)
      end

    standard_headers =
      [
        {"content-type", "application/json"},
        {"ce-specversion", "1.0"},
        {"ce-type", event.type},
        {"ce-source", event.source},
        {"ce-id", event.id}
      ]
      |> add_if_set(event, :subject, as: "ce-subject")
      |> add_if_set(event, :time, as: "ce-time")

    extensions_as_headers = for {name, value} <- event.extensions, do: {"ce-#{name}", value}

    {body, standard_headers ++ extensions_as_headers}
  end

  # ---

  defp add_if_set(headers, event, key, as: header_name) do
    case Map.get(event, key) do
      nil -> headers
      val -> headers ++ [{header_name, val}]
    end
  end

  # ---

  @spec to_structured_content_mode(Cloudevents.t(), :json | :avro_binary) ::
          {:ok, {Cloudevents.http_body(), Cloudevents.http_headers()}} | {:error, term}
  def to_structured_content_mode(event, event_format)

  def to_structured_content_mode(event, :json) do
    body = Cloudevents.to_json(event)
    headers = [{"content-type", "application/cloudevents+json"}]
    {:ok, {body, headers}}
  end

  # ---

  def to_batched_content_mode(_events) do
    # TODO
    raise "Not implemented."
  end
end
