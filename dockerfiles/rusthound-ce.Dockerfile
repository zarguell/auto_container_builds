FROM cgr.dev/chainguard/rust:latest-dev AS builder
WORKDIR /usr/src/rusthound-ce

# Clone source
RUN git clone https://github.com/g0h4n/RustHound-CE.git .

# Set environment variables and execute all build steps in a single shell
RUN export CARGO_HOME=/home/nonroot/.cargo && \
    export RUSTUP_HOME=/home/nonroot/.rustup && \
    export PATH=/home/nonroot/.cargo/bin:${PATH} && \
    cargo install --version 0.1.16 cross && \
    rustup default stable && \
    rustup target add x86_64-unknown-linux-musl && \
    make build_linux_musl

FROM cgr.dev/chainguard/wolfi-base:latest
WORKDIR /app
COPY --from=builder /usr/src/rusthound-ce/target/x86_64-unknown-linux-musl/release/rusthound-ce /app/rusthound-ce
ENTRYPOINT ["./rusthound-ce"]
