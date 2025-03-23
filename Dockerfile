FROM rust:bookworm AS rustbuilder
ARG MITHRIL_VERSION=2506.0
ENV MITHRIL_VERSION=${MITHRIL_VERSION}
WORKDIR /code
RUN echo "Building tags/${MITHRIL_VERSION}..." \
    && git clone https://github.com/input-output-hk/mithril.git --depth 1 -b ${MITHRIL_VERSION} \
    && cd mithril \
    && git checkout tags/${MITHRIL_VERSION} \
    && cargo build --release -p mithril-client-cli

FROM ghcr.io/blinklabs-io/cardano-configs:20250213-1 AS cardano-configs

FROM debian:bookworm-slim AS mithril-client
COPY --from=rustbuilder /code/mithril/target/release/mithril-client /bin/
COPY --from=cardano-configs /config/ /opt/cardano/config/
RUN apt-get update -y \
    && apt-get install -y \
       ca-certificates \
       libssl3 \
       llvm-14-runtime \
       sqlite3 curl\
       wget jq\
    && rm -rf /var/lib/apt/lists/*
ENTRYPOINT ["/bin/mithril-client", "-vvv"]