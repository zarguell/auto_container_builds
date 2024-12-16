FROM debian:bullseye-slim

# Set working directory
WORKDIR /app

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    PATH="/root/go/bin:/app/PEzor:/app/PEzor/deps/donut:/app/PEzor/deps/wclang/_prefix_PEzor_/bin:/app/wclang/_prefix_/bin:/usr/local/go/bin:${PATH}"

# Install required packages, combining commands and cleaning up afterwards
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        wget git clang g++ cmake mingw-w64 unzip build-essential \
        autotools-dev libcapstone-dev libssl-dev cowsay mono-devel && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone the PEzor repository
RUN git clone https://github.com/Nahid5/PEzor /app/PEzor

# Run the installation script for PEzor
RUN /app/PEzor/install.sh

# Set the entrypoint to the PEzor script
ENTRYPOINT ["/app/PEzor/PEzor.sh"]
