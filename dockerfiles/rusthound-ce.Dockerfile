# Stage 1: Build RustHound-CE
FROM rust:1.81.0-slim-bullseye AS builder

# Set the working directory
WORKDIR /usr/src/rusthound-ce

# Install required dependencies
RUN apt-get -y update && \
    apt-get -y install \
        gcc \
        clang \
        libclang-dev \
        libgssapi-krb5-2 \
        libkrb5-dev \
        libsasl2-modules-gssapi-mit \
        musl-tools \
        make \
        gcc-mingw-w64-x86-64 \
        git && \
    rm -rf /var/lib/apt/lists/*

# Clone the RustHound-CE source code
RUN git clone https://github.com/g0h4n/RustHound-CE.git .

# Build the release version of the project
RUN make release

# Stage 2: Minimal image with the built binary
FROM debian:bullseye-slim

# Set working directory
WORKDIR /app

# Copy the RustHound-CE binary from the builder stage
COPY --from=builder /usr/src/rusthound-ce/rusthound-ce /app/rusthound-ce

# Set the entrypoint to the RustHound-CE binary
ENTRYPOINT ["./rusthound-ce"]
