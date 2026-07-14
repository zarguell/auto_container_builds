# syntax=docker/dockerfile:1
FROM node:22-bookworm-slim@sha256:b16ca7b4dcfb20184e1c70f9ee30c6a75ed1da669cfafd6d2add4761b123d79f

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

# renovate: datasource=npm depName=@earendil-works/pi-coding-agent
ARG PI_CODING_AGENT_VERSION=0.80.7
# renovate: datasource=npm depName=@jmfederico/pi-web
ARG PI_WEB_VERSION=1.202607.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        curl \
        ca-certificates \
        jq \
        openssh-client \
        procps \
    && rm -rf /var/lib/apt/lists/*

# Install Pi Coding Agent and PI WEB at pinned versions
RUN --mount=type=cache,target=/root/.npm \
    set -eux \
    && npm_config_retry=5 npm_config_retry_timeout=30000 \
    npm install -g \
        "@earendil-works/pi-coding-agent@${PI_CODING_AGENT_VERSION}" \
        "@jmfederico/pi-web@${PI_WEB_VERSION}" \
    && npm list -g --depth=0

# Create workspace directory, use node user
RUN mkdir -p /workspace && chown node:node /workspace

COPY --chmod=755 entrypoint.sh /entrypoint.sh

USER node
WORKDIR /workspace

ENV PI_WEB_HOST=0.0.0.0
ENV PI_WEB_PORT=8504
ENV PI_WEB_SESSIOND_SOCKET=/tmp/pi-web-sessiond.sock

EXPOSE 8504

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -fsS http://localhost:8504/ > /dev/null 2>&1 || exit 1

ENTRYPOINT ["/entrypoint.sh"]
