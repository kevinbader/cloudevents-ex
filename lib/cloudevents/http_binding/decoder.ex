defmodule Cloudevents.HttpBinding.Decoder do
  @moduledoc false

  alias Cloudevents.HttpBinding.V_1_0

  @doc """
  Turns an HTTP request into a Cloudevent.

  The latest transport binding spec is used to parse the HTTP message. In case of a
  parsing error, older versions of the spec may be considered as a fallback.
  """
  @spec from_http_message(Cloudevents.http_body(), Cloudevents.http_headers()) ::
          Cloudevents.cloudevent_result()
  def from_http_message(http_body, http_headers) do
    with {:error, _} = error <- V_1_0.Decoder.from_http_message(http_body, http_headers) do
      error
    else
      {:ok, events} -> {:ok, events}
    end
  end
end
