FROM rust:1.89 AS builder
# Debian GNU/Linux 13 (trixie)

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    clang \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency files first for better caching
COPY Cargo.toml Cargo.lock ./

# Create a dummy main.rs to build dependencies
RUN mkdir src && echo "fn main() {}" > src/main.rs

# Build dependencies (this layer will be cached)
RUN cargo build --release --locked && rm -rf src target/release/deps/ckb_bitcoin_spv_service*

# Copy source code
COPY src ./src

# Build the actual application
RUN cargo build --release --locked

FROM debian:trixie-slim

ARG DEBCONF_NOWARNINGS="yes"
ARG DEBIAN_FRONTEND noninteractive
ARG DEBCONF_NONINTERACTIVE_SEEN true

RUN apt-get update \
 && apt-get install --no-install-recommends -y \
    ca-certificates \
    curl \
    netcat-openbsd \
    tini \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=builder /app/target/release/ckb-bitcoin-spv-service /usr/local/bin/ckb-bitcoin-spv-service

RUN chmod a+x /usr/local/bin/ckb-bitcoin-spv-service

ENTRYPOINT [ "tini", "--"]
CMD ["ckb-bitcoin-spv-service", "--help"]
