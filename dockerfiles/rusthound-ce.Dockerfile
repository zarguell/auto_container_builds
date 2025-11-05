FROM cgr.dev/chainguard/rust:latest-dev AS builder

WORKDIR /usr/src/rusthound-ce

RUN git clone https://github.com/g0h4n/RustHound-CE.git .
RUN make linux_musl

FROM cgr.dev/chainguard/wolfi-base:latest

WORKDIR /app

COPY --from=builder /usr/src/rusthound-ce/rusthound-ce_musl /app/rusthound-ce

ENTRYPOINT ["./rusthound-ce"]
