FROM cgr.dev/chainguard/rust:latest-dev AS builder

WORKDIR /usr/src/rusthound-ce

# Clone source
RUN git clone https://github.com/g0h4n/RustHound-CE.git .

# Install cross (Rust cross-compilation tool)
RUN cargo install cross

# Ensure musl target is available
RUN rustup default stable
RUN rustup target add x86_64-unknown-linux-musl

# Now build static binary
RUN make linux_musl

FROM cgr.dev/chainguard/wolfi-base:latest

WORKDIR /app

COPY --from=builder /usr/src/rusthound-ce/rusthound-ce_musl /app/rusthound-ce

ENTRYPOINT ["./rusthound-ce"]
