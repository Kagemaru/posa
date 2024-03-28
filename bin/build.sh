#!/usr/bin/env bash

set -euxo pipefail

export MIX_ENV=prod 

# Initial setup
mix deps.get --only prod
mix deps.compile
mix compile

# Compile assets
mix phx.digest

# Build phoenix
mix phx.gen.release

# Build the release
mix release
