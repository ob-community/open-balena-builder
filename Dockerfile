FROM node:22-bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    nodejs \
    node-typescript \
    jq \
    docker-compose \
    curl \
    tar \
    gzip \
    && rm -rf /var/lib/apt/lists/*

ARG BALENA_CLI_VERSION=22.5.5
ENV BALENA_CLI_DIR=/usr/local/balena-cli
ENV PATH="${BALENA_CLI_DIR}/balena/bin:${PATH}"

RUN curl -fsSL \
    "https://github.com/balena-io/balena-cli/releases/download/v${BALENA_CLI_VERSION}/balena-cli-v${BALENA_CLI_VERSION}-linux-x64-standalone.tar.gz" \
    -o balena-cli.tar.gz && \
  mkdir -p "${BALENA_CLI_DIR}" && \
  tar -xzf balena-cli.tar.gz -C "${BALENA_CLI_DIR}" && \
  rm balena-cli.tar.gz

WORKDIR /usr/src/app

COPY ./src ./src
COPY ./tsconfig.json ./
COPY ./package.json ./
COPY ./package-lock.json ./

RUN npm ci --no-fund --no-update-notifier && \
    tsc

COPY ./start.sh ./

CMD ["/bin/sh", "/usr/src/app/start.sh"]
