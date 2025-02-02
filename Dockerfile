FROM rust AS builder
RUN apt-get update -y && \
    apt-get install -y pkg-config libssl-dev
WORKDIR /usr/src/plantuml-generator
COPY Cargo.toml Cargo.lock /usr/src/plantuml-generator/
COPY src /usr/src/plantuml-generator/src
RUN cargo build --release --features vendored-openssl

FROM ubuntu:focal
ARG git_sha=""
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.vendor="tmorin" \
      org.label-schema.license="MIT" \
      org.label-schema.vcs-ref="$git_sha" \
      org.label-schema.vcs-url="https://github.com/tmorin/plantuml-generator"
RUN apt-get update -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:inkscape.dev/stable -y && \
    apt-get install -y openjdk-11-jre graphviz inkscape && \
    apt-get purge -y software-properties-common && \
    apt-get autoremove -y --purge && \
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/src/plantuml-generator/target/release/plantuml-generator /usr/local/bin/plantuml-generator
WORKDIR /workdir
CMD ["/usr/local/bin/plantuml-generator"]
