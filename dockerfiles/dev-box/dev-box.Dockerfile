# syntax=docker/dockerfile:1
# dev-box — "dev in a box": OpenHands Agent Canvas + Pi coding agent + pi-acp
# plus a full local dev toolchain (python3, uv, node/npm, git, tmux, ...).
#
# Default mode (entrypoint, no args) runs Agent Canvas: an ingress proxy on
# :8000 routing to the agent-server (:18000) and automation backend (:18001),
# both spawned via uvx. `docker compose run --rm dev-box shell` gives a raw
# interactive dev shell instead. Pi (via `pi-acp`) is wired into Canvas from
# Settings → Agent → ACP → Custom with command `pi-acp`.
#
# Runs as a non-root `coder` user (uid/gid 1000) with passwordless sudo, like
# the code-server containers. The entrypoint (running as root) remaps
# PUID/PGID, chowns the mounted workspace/state dirs, then drops privileges.
FROM node:24-bookworm-slim@sha256:6f7b03f7c2c8e2e784dcf9295400527b9b1270fd37b7e9a7285cf83b6951452d

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

# ── Version pins (renovate-managed) ────────────────────────────────
# renovate: datasource=npm depName=@openhands/agent-canvas
ARG AGENT_CANVAS_VERSION=1.9.0
# renovate: datasource=npm depName=@earendil-works/pi-coding-agent
ARG PI_CODING_AGENT_VERSION=0.83.0
# renovate: datasource=npm depName=pi-acp
ARG PI_ACP_VERSION=0.0.33

# These are the PyPI packages agent-canvas spawns via uvx at runtime.
# They must stay in sync with config/defaults.json inside the
# @openhands/agent-canvas package (versions + the agent-client-protocol
# upper-bound constraint).
# renovate: datasource=pypi depName=openhands-agent-server
ARG AGENT_SERVER_VERSION=1.39.1
# renovate: datasource=pypi depName=openhands-automation
ARG AUTOMATION_VERSION=1.5.0

# ── System packages ────────────────────────────────────────────────
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        curl \
        wget \
        ca-certificates \
        jq \
        openssh-client \
        procps \
        psmisc \
        # agent-server runs agent bash sessions under tmux
        tmux \
        python3 \
        python3-pip \
        build-essential \
        unzip \
        zip \
        less \
        vim \
        nano \
        tree \
        file \
        make \
        ripgrep \
        sudo \
    && rm -rf /var/lib/apt/lists/*

# ── uv — fast Python package manager, copied from official image ───
COPY --from=ghcr.io/astral-sh/uv:0.11.8@sha256:3b7b60a81d3c57ef471703e5c83fd4aaa33abcd403596fb22ab07db85ae91347 \
    /uv /uvx /usr/local/bin/
ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

# ── npm tools at pinned versions (system-wide, root-owned) ─────────
RUN --mount=type=cache,target=/root/.npm \
    set -eux \
    && npm_config_retry=5 npm_config_retry_timeout=30000 \
    npm install -g \
        "@openhands/agent-canvas@${AGENT_CANVAS_VERSION}" \
        "@earendil-works/pi-coding-agent@${PI_CODING_AGENT_VERSION}" \
        "pi-acp@${PI_ACP_VERSION}" \
    && npm list -g --depth=0 \
    && agent-canvas --version \
    && pi --version \
    && pi-acp --version

# ── Non-root dev user with passwordless sudo (code-server style) ───
# Base node image ships a `node` user at uid 1000 — rename it to coder
# rather than creating a second uid-1000 account.
RUN set -eux \
    && groupmod --new-name coder node \
    && usermod --login coder --move-home --home /home/coder --shell /bin/bash node \
    && echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/coder \
    && chmod 440 /etc/sudoers.d/coder \
    && mkdir -p /projects /home/coder/.openhands /home/coder/.pi \
    && chown -R coder:coder /projects /home/coder

# ── Pre-warm uvx environments (as coder, so the wheel cache lands in
#    /home/coder/.cache/uv and survives into the image) ─────────────
# `python -c "print(...)"` forces uv to resolve and install the ephemeral
# environment; the argument sets must match what scripts/dev-safe.mjs /
# dev-with-automation.mjs build at runtime. Intentionally NOT a cache
# mount — we want the wheels inside the image.
USER coder
ENV HOME=/home/coder
RUN set -eux \
    && uvx \
        --from "openhands-agent-server==${AGENT_SERVER_VERSION}" \
        --with "openhands-sdk==${AGENT_SERVER_VERSION}" \
        --with "openhands-tools==${AGENT_SERVER_VERSION}" \
        --with "openhands-workspace==${AGENT_SERVER_VERSION}" \
        --with "agent-client-protocol<0.11" \
        python -c "print('agent-server env warmed')" \
    && uvx \
        --from "openhands-automation==${AUTOMATION_VERSION}" \
        python -c "print('automation env warmed')"

# ── Runtime layout ─────────────────────────────────────────────────
# Entrypoint runs as root so it can remap PUID/PGID + chown mounts, then
# drops to coder via setpriv. State persists via mounts:
#   /projects              → working code (agents read/write it)
#   /home/coder/.openhands → Agent Canvas settings, secrets, conversations
#   /home/coder/.pi        → Pi config, credentials, sessions
COPY --chmod=755 entrypoint.sh /entrypoint.sh

USER root
WORKDIR /projects
ENV PORT=8000

EXPOSE 8000 18000 18001

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -fsS http://localhost:8000/ > /dev/null 2>&1 || exit 1

ENTRYPOINT ["/entrypoint.sh"]
