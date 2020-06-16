defmodule Cloudevents.Config do
  @moduledoc false
  use Agent

  @spec start_link(Cloudevents.options()) :: {:ok, pid} | {:error, term}
  def start_link(opts), do: Agent.start_link(fn -> opts end, name: __MODULE__)

  def avro_event_schema_name, do: Agent.get(__MODULE__, &Keyword.get(&1, :avro_event_schema_name))
end
