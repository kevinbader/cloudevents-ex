defmodule Cloudevents.Format.V_0_1.Event do
  @desc "Cloudevents format v0.1."
  @moduledoc @desc
  use TypedStruct

  @typedoc @desc
  typedstruct do
    field(:cloud_events_version, String.t(), default: "0.1")
    field(:event_type, String.t(), enforce: true)
    field(:source, String.t(), enforce: true)
    field(:event_id, String.t(), enforce: true)
    field(:event_time, String.t())
    field(:content_type, String.t())
    field(:data, any)
  end
end
