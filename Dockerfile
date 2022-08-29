FROM node:18-alpine as node

WORKDIR /assets

COPY assets/package.json assets/package-lock.json /assets
RUN npm install

#-------------------------

ARG MIX_ENV="dev"
ARG SECRET_KEY_BASE=""

FROM elixir:1.13-otp-25

# Install build dependencies
RUN apt-get update && \
    apt-get install -y inotify-tools postgresql-client

# Prepare build dir
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Set build ENV
ENV MIX_ENV="${MIX_ENV}"
ENV SECRET_KEY_BASE="${SECRET_KEY_BASE}"

# Install mix dependencies
COPY mix.exs mix.lock ./
RUN mix deps.get

# Copy compile-time config files
COPY config config
RUN mix deps.compile

COPY priv priv

COPY assets assets
COPY --from=node /assets/node_modules assets/node_modules

# Compile assets
RUN mix assets.deploy

# Compile the release
COPY lib lib

COPY fixtures fixtures
COPY test test

RUN mix compile

COPY script-code-coverage.sh ./
COPY script-entry-point.sh ./

RUN chmod u+x script-entry-point.sh

EXPOSE 4000

CMD [ "/app/script-entry-point.sh" ]