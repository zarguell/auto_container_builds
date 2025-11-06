FROM cgr.dev/chainguard/rust:latest-dev AS builder
WORKDIR /usr/src/rusthound-ce

# Clone source
RUN git clone https://github.com/g0h4n/RustHound-CE.git .

# Ensure cargo/cross are installed into a predictable, writable location
ENV CARGO_HOME=/home/nonroot/.cargo \
    RUSTUP_HOME=/home/nonroot/.rustup \
    PATH=/home/nonroot/.cargo/bin:/usr/local/cargo/bin:${PATH}

# Install a compatible cross version the Makefile expects
RUN cargo install --version 0.1.16 cross

# Ensure the musl target is available
RUN rustup default stable && rustup target add x86_64-unknown-linux-musl

# Build using the Makefile's build target (build_linux_musl avoids running install_cross)
RUN make build_linux_musl

FROM cgr.dev/chainguard/wolfi-base:latest
WORKDIR /app
COPY --from=builder /usr/src/rusthound-ce/target/x86_64-unknown-linux-musl/release/rusthound-ce /app/rusthound-ce
ENTRYPOINT ["./rusthound-ce"]
