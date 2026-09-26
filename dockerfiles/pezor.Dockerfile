FROM debian:13.7-slim@sha256:a99cfc517144bc59b1978475ec53b46ecabec7e43635402ee5b77cc54cd1b20a

# Set working directory
WORKDIR /app

# Set environment variables to avoid interactive prompts and enable Go modules
ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    PIP_REQUIRE_VIRTUALENV=false \
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

# Clone repo, patch install.sh to fix PEP 668 and sudo, then run it
# Note: 'go install ...@latest' is the modern Go form (Go 1.16+) — no sed needed
RUN git clone https://github.com/phra/PEzor.git /app/PEzor && \
    sed -i 's/sudo //g' /app/PEzor/install.sh && \
    sed -i 's|pip3 install --no-warn-script-location|pip3 install --break-system-packages --no-warn-script-location|' /app/PEzor/install.sh && \
    /app/PEzor/install.sh

# Set the entrypoint to the PEzor script
ENTRYPOINT ["/app/PEzor/PEzor.sh"]
