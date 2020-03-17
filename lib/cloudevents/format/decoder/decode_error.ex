defmodule Cloudevents.Format.Decoder.DecodeError do
  @moduledoc "What was given could not be decoded to a Cloudevent."
  defexception [:cause]

  def message(%__MODULE__{cause: cause}),
    do: "Failed to decode Cloudevent: #{Exception.message(cause)}"
end
