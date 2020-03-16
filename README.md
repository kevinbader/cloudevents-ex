# Cloudevents

An Elixir library for handling [CloudEvents](https://cloudevents.io/) (make sure to check out the [spec on GitHub](https://github.com/cloudevents/spec)).

## Status

Work in progress.

| Spec                         | Status                            |
| :--------------------------- | :-------------------------------- |
| **Core Specification:**      |                                   |
| CloudEvents                  | Support for v1.0 is there.        |
|                              |                                   |
| **Optional Specifications:** |                                   |
| AMQP Protocol Binding        | out of scope for now (PR welcome) |
| AVRO Event Format            | todo (PR welcome)                 |
| HTTP Protocol Binding        | wip (done except batch mode)      |
| JSON Event Format            | done                              |
| Kafka Protocol Binding       | todo (PR welcome)                 |
| MQTT Protocol Binding        | out of scope for now (PR welcome) |
| NATS Protocol Binding        | out of scope for now (PR welcome) |
| Web hook                     | out of scope for now (PR welcome) |

## Installation

Add `cloudevents` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:cloudevents, "~> 0.1.0"}]
end
```

## Basic Usage

Check out the [documentation](https://hexdocs.pm/cloudevents).

## License

Cloudevents is released under the Apache License 2.0 - see the [LICENSE](LICENSE) file.
