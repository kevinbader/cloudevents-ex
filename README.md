<span id="badges">

[![Hex pm](https://img.shields.io/hexpm/v/cloudevents.svg?style=flat-square)](https://hex.pm/packages/cloudevents)
[![Hex Docs](https://img.shields.io/badge/api-docs-blue.svg?style=flat-square)](https://hexdocs.pm/cloudevents)
[![Apache 2.0 license](https://img.shields.io/hexpm/l/cloudevents.svg?style=flat-square)](./LICENSE)

</span>

Cloudevents is an Elixir [SDK] for consuming and producing [CloudEvents] with support for various transport protocols and codecs. If you want to learn more about the specification itself, make sure to check out the [official spec on GitHub].

Cloudevents is released under the Apache License 2.0 - see the [LICENSE](LICENSE) file.

[CloudEvents]: https://cloudevents.io/
[SDK]: https://github.com/cloudevents/spec/blob/master/SDK.md
[official spec on GitHub]: https://github.com/cloudevents/spec

<div id="status">

## Supported versions

* OTP 25.0 and later
* Elixir 1.13 and later

## Status

| Spec                         | Status                            |
| :--------------------------- | :-------------------------------- |
| **Core Specification:**      |                                   |
| CloudEvents                  | v0.1, v0.2, v1.0                  |
|                              |                                   |
| **Optional Specifications:** |                                   |
| AMQP Protocol Binding        | out of scope for now (PR welcome) |
| AVRO Event Format            | todo (PR welcome)                 |
| HTTP Protocol Binding        | wip (done except batch mode)      |
| JSON Event Format            | done                              |
| Kafka Protocol Binding       | v1.0                              |
| MQTT Protocol Binding        | out of scope for now (PR welcome) |
| NATS Protocol Binding        | out of scope for now (PR welcome) |
| Web hook                     | out of scope for now (PR welcome) |

</div>

## Getting started

Add `cloudevents` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:cloudevents, "~> 0.5.1"}]
end
```

Use `Cloudevents.from_map/1` to create your first Cloudevent and see its JSON representation using `Cloudevents.to_json/1`.

If you're dealing with HTTP requests, `Cloudevents.from_http_message/2`, `Cloudevents.to_http_binary_message/1` and `Cloudevents.to_http_structured_message/2` are your friends.

If you need Avro, you need to add `avrora` to your dependency list:
```elixir
def deps do
  [{:avrora, "~> 0.21"}]
end
```

Then, you need to add `Cloudevents` to your supervisor:

```elixir
children = [
  Cloudevents
]

Supervisor.start_link(children, strategy: :one_for_one)
```

Or start `Cloudevents` manually:

```elixir
{:ok, pid} = Cloudevents.start_link()
```
