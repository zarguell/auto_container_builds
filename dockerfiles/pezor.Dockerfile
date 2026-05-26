FROM debian:13.5-slim@sha256:b6e2a152f22a40ff69d92cb397223c906017e1391a73c952b588e51af8883bf8

# Set working directory
WORKDIR /app

# Set environment variables to avoid interactive prompts and enable Go modules
ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    PATH="/root/go/bin:/app/PEzor:/app/PEzor/deps/donut:/app/PEzor/deps/wclang/_prefix_PEzor_/bin:/usr/local/go/bin:${PATH}" \
    GO111MODULE=on

# Install required dependencies
RUN apt-get update && \
    apt-get install --no-install-recommends -y \
        wget git clang g++ cmake autotools-dev build-essential \
        mingw-w64 unzip libcapstone-dev libssl-dev cowsay mono-devel \
        python3-pip golang wine64-tools && \
    pip3 install --break-system-packages --no-warn-script-location xortool && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Clone repo,remove 'sudo' commands from the installation script and run the installation script for PEzor
RUN git clone https://github.com/phra/PEzor.git /app/PEzor && \
    sed -i 's/go install/go get/' /app/PEzor/install.sh && \
    sed -i 's/sudo //g' /app/PEzor/install.sh && \
    /app/PEzor/install.sh

# Set the entrypoint to the PEzor script
ENTRYPOINT ["/app/PEzor/PEzor.sh"]
