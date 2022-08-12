#!/bin/bash
new_version="$1"
sed -i "0,/version: \"/s/version: \".*\"/version: \"$new_version\"/" mix.exs
sed -i -E "s/\{:cloudevents, \"~> .*\"\}/\{:cloudevents, \"~> $new_version\"\}/" README.md
