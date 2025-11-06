FROM cgr.dev/chainguard/rust:latest-dev AS builder
WORKDIR /usr/src/rusthound-ce

# Clone source
RUN git clone https://github.com/g0h4n/RustHound-CE.git .

# Set default toolchain and install musl target
RUN rustup default stable && \
    rustup target add x86_64-unknown-linux-musl

# Build directly with cargo instead of using cross/make
RUN cargo build --target x86_64-unknown-linux-musl --release --features nogssapi --no-default-features

FROM cgr.dev/chainguard/wolfi-base:latest
WORKDIR /app
COPY --from=builder /usr/src/rusthound-ce/target/x86_64-unknown-linux-musl/release/rusthound-ce /app/rusthound-ce
ENTRYPOINT ["./rusthound-ce"]
