defmodule Cloudevents.Format.ParseError do
  @moduledoc "What was given does not look like a proper Cloudevent."
  defexception [:message]
end
