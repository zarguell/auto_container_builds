# syntax=docker/dockerfile:1
FROM node:24-bookworm-slim@sha256:6f7b03f7c2c8e2e784dcf9295400527b9b1270fd37b7e9a7285cf83b6951452d

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

# renovate: datasource=npm depName=@earendil-works/pi-coding-agent
ARG PI_CODING_AGENT_VERSION=0.80.7
# renovate: datasource=npm depName=@jmfederico/pi-web
ARG PI_WEB_VERSION=1.202607.0

# renovate: datasource=npm depName=opencode-ai
ARG OPENCODE_VERSION=1.18.3
# renovate: datasource=npm depName=@anthropic-ai/claude-code
ARG CLAUDE_CODE_VERSION=2.1.209

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        curl \
        ca-certificates \
        jq \
        openssh-client \
        procps \
        python3 \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

# uv — fast Python package manager, copied from official image
COPY --from=ghcr.io/astral-sh/uv:0.11.8@sha256:3b7b60a81d3c57ef471703e5c83fd4aaa33abcd403596fb22ab07db85ae91347 \
    /uv /uvx /usr/local/bin/
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=never

# Install npm-based tools at pinned versions
RUN --mount=type=cache,target=/root/.npm \
    set -eux \
    && npm_config_retry=5 npm_config_retry_timeout=30000 \
    npm install -g \
        "@earendil-works/pi-coding-agent@${PI_CODING_AGENT_VERSION}" \
        "@jmfederico/pi-web@${PI_WEB_VERSION}" \
        "opencode-ai@${OPENCODE_VERSION}" \
        "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}" \
    && npm list -g --depth=0 \
    && opencode --version \
    && claude --version

# Run as root so the agent can install tools (apt, npm, pip, etc.).
# The container IS the security boundary — see SECURITY in README.md.
# pam: root, intentional — agent containers that can't install tools get
#   piped around by users anyway, which is strictly worse.
RUN mkdir -p /workspace

COPY --chmod=755 entrypoint.sh /entrypoint.sh

USER root
WORKDIR /workspace

ENV PI_WEB_HOST=0.0.0.0
ENV PI_WEB_PORT=8504
ENV PI_WEB_SESSIOND_SOCKET=/tmp/pi-web-sessiond.sock

EXPOSE 8504

HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -fsS http://localhost:8504/ > /dev/null 2>&1 || exit 1

ENTRYPOINT ["/entrypoint.sh"]
