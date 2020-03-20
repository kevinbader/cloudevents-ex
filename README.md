# Cloudevents

<span id="badges">

[![Hex pm](https://img.shields.io/hexpm/v/cloudevents.svg?style=flat-square)](https://hex.pm/packages/cloudevents)
[![Hex Docs](https://img.shields.io/badge/api-docs-blue.svg?style=flat-square)](https://hexdocs.pm/cloudevents)
[![Apache 2.0 license](https://img.shields.io/hexpm/l/cloudevents.svg?style=flat-square)](./LICENSE)

</span>

A batteries-included approach to consuming and producing [CloudEvents](https://cloudevents.io/). If you want to learn more about the specification itself, make sure to check out the [official spec on GitHub](https://github.com/cloudevents/spec).

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
