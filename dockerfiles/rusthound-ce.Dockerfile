FROM cgr.dev/chainguard/rust:latest-dev AS builder
WORKDIR /usr/src/rusthound-ce

# Install OpenSSL development dependencies
USER root
RUN apk add --no-cache openssl-dev pkgconf
USER nonroot

# Clone source
RUN git clone https://github.com/g0h4n/RustHound-CE.git .

# Build with nogssapi
RUN cargo build --release --features nogssapi --no-default-features

FROM cgr.dev/chainguard/glibc-dynamic:latest
WORKDIR /app

# Copy the binary
COPY --from=builder /usr/src/rusthound-ce/target/release/rusthound-ce /app/rusthound-ce

ENTRYPOINT ["./rusthound-ce"]
