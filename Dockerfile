FROM node:18-alpine as node

WORKDIR /assets

COPY assets/package.json assets/package-lock.json /assets
RUN npm install

#-------------------------

ARG MIX_ENV="dev"
ARG SECRET_KEY_BASE=""

FROM elixir:1.13-otp-25

RUN apt-get update && \
    apt-get install -y inotify-tools postgresql-client

WORKDIR /app

RUN mix archive.install github hexpm/hex branch latest --force && \
    mix local.rebar --force

ENV MIX_ENV="${MIX_ENV}"
ENV SECRET_KEY_BASE="${SECRET_KEY_BASE}"

COPY . .
COPY --from=node /assets/node_modules assets/node_modules

RUN mix deps.get && \
    mix deps.compile && \
    mix assets.deploy && \
    mix compile

RUN chmod u+x script-entry-point.sh

EXPOSE 4000

CMD [ "/app/script-entry-point.sh" ]