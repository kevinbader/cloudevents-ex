defmodule Cloudevents.Format.V_0_2.Event do
  @desc "Cloudevents format v0.2."
  @moduledoc @desc
  use TypedStruct

  @typedoc @desc
  typedstruct do
    field(:specversion, String.t(), default: "0.2")
    field(:type, String.t(), enforce: true)
    field(:source, String.t(), enforce: true)
    field(:id, String.t(), enforce: true)
    field(:time, String.t())
    field(:contenttype, String.t())
    field(:data, any)
  end
end
