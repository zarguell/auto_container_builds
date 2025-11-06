FROM cgr.dev/chainguard/rust:latest-dev AS builder
WORKDIR /usr/src/rusthound-ce

RUN git clone https://github.com/g0h4n/RustHound-CE.git .
RUN cargo build --release --features nogssapi --no-default-features

FROM cgr.dev/chainguard/glibc-dynamic:latest
WORKDIR /app
COPY --from=builder /usr/src/rusthound-ce/target/release/rusthound-ce /app/rusthound-ce
ENTRYPOINT ["./rusthound-ce"]
