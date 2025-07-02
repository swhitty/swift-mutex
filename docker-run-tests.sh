#!/usr/bin/env bash

set -eu

docker run -it \
  --rm \
  --mount src="$(pwd)",target=/mutex,type=bind \
  swiftlang/swift:nightly-6.2-noble \
  /usr/bin/swift test --package-path /mutex
