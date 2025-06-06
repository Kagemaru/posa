# ===================================================================================
FROM hexpm/elixir:1.18.4-erlang-27.3.4-alpine-3.21.3 AS build

# install build dependencies
# RUN apk add --no-cache build-base npm git python
RUN apk update && apk add --no-cache build-base npm git libgcc libstdc++ make

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY mix.exs mix.lock ./
COPY config config
RUN mix do deps.get, deps.compile

COPY priv priv
COPY assets assets
COPY lib lib
# uncomment COPY if rel/ exists
# COPY rel rel

# build assets, digest files, compile, build release and clean up
RUN mix assets.deploy \
    && mix compile \
    && mix release \
    && mix phx.digest.clean --all

# ===================================================================================
# prepare release image
FROM alpine:3.21 AS app

# Add User
RUN adduser -D posa

RUN apk update \
    && apk upgrade --no-cache \
    && apk add --no-cache postgresql-client bash openssl libgcc libstdc++ ncurses-libs make

WORKDIR /app

# Copy release to running image
COPY --from=build /app/_build/prod/rel/posa ./

RUN chgrp -R 0 /app \
    && chmod -R g=u /app

# USER nobody:nobody
USER posa

ENV HOME=/app

# Starts Posa
# CMD ["bin/posa", "start"]
ENTRYPOINT ["bin/posa", "start"]
