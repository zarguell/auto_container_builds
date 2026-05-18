FROM docker.io/nousresearch/hermes-agent:v2026.5.7@sha256:9462082533e603fc6ba4259c51d7722dcd8cbb0f348488ceedc35d06fa8f9324

COPY --from=ghcr.io/astral-sh/uv:0.11.8 /uv /uvx /usr/local/bin/

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PYTHON_DOWNLOADS=never

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

# ── System deps + supervisor ──────────────────────────────────────
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        curl \
        wget \
        jq \
        ca-certificates \
        gnupg \
        dirmngr \
        unzip \
        zip \
        xz-utils \
        openssh-client \
        procps \
        psmisc \
        less \
        vim \
        nano \
        tree \
        rsync \
        file \
        make \
        gawk \
        sed \
        grep \
        findutils \
        coreutils \
        lsb-release \
        supervisor \
    && rm -rf /var/lib/apt/lists/*

# ── gh-dl helper ───────────────────────────────────────────────────
RUN cat > /usr/local/lib/gh-dl.sh <<'SCRIPT'
#!/usr/bin/env bash
gh-dl() {
    local url="$1" output="$2" cache_key="${3:-$(basename "$output")}"
    local cache_file="/tmp/tool-cache/${cache_key}"

    if [ -f "${cache_file}" ]; then
        echo "gh-dl: cache hit ${cache_key}"
        cp "${cache_file}" "${output}"
        return 0
    fi

    echo "gh-dl: downloading ${url}"
    local curl_opts=(--retry 5 --retry-delay 10 --retry-all-errors -fsSL)
    if [ -n "${GITHUB_TOKEN:-}" ]; then
        curl_opts+=(-H "Authorization: Bearer ${GITHUB_TOKEN}")
    fi
    curl "${curl_opts[@]}" "${url}" -o "${output}"
    cp "${output}" "${cache_file}"
}
SCRIPT

# ── Architecture detection ─────────────────────────────────────────
RUN set -eux; \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch}" in \
      amd64) \
        export RUST_GNU="x86_64-unknown-linux-gnu"; \
        export RUST_MUSL="x86_64-unknown-linux-musl"; \
        export GO_ARCH="amd64"; \
        export FZF_ARCH="linux_amd64"; \
        export DEB_ARCH="amd64"; \
        ;; \
      arm64) \
        export RUST_GNU="aarch64-unknown-linux-gnu"; \
        export RUST_MUSL="aarch64-unknown-linux-musl"; \
        export GO_ARCH="arm64"; \
        export FZF_ARCH="linux_arm64"; \
        export DEB_ARCH="arm64"; \
        ;; \
      *) echo "Unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac; \
    cat > /etc/tool-arch.env <<EOF
RUST_GNU=${RUST_GNU}
RUST_MUSL=${RUST_MUSL}
GO_ARCH=${GO_ARCH}
FZF_ARCH=${FZF_ARCH}
DEB_ARCH=${DEB_ARCH}
EOF

# ── Dev tools ──────────────────────────────────────────────────────

# renovate: datasource=github-releases depName=cli/cli
ARG GH_VERSION=2.92.0
RUN --mount=type=cache,target=/tmp/tool-cache \
    --mount=type=secret,id=github_token \
    set -eux; \
    source /usr/local/lib/gh-dl.sh; \
    export GITHUB_TOKEN="$(cat /run/secrets/github_token 2>/dev/null || echo '')"; \
    source /etc/tool-arch.env; \
    asset="gh_${GH_VERSION}_linux_${DEB_ARCH}.deb"; \
    base="https://github.com/cli/cli/releases/download/v${GH_VERSION}"; \
    gh-dl "${base}/${asset}" "/tmp/${asset}"; \
    gh-dl "${base}/gh_${GH_VERSION}_checksums.txt" /tmp/gh_checksums.txt; \
    cd /tmp; \
    grep " ${asset}$" gh_checksums.txt | sha256sum -c -; \
    dpkg -i "/tmp/${asset}"; \
    rm -f "/tmp/${asset}" /tmp/gh_checksums.txt

# renovate: datasource=github-releases depName=sharkdp/bat
ARG BAT_VERSION=v0.26.1
RUN --mount=type=cache,target=/tmp/tool-cache \
    --mount=type=secret,id=github_token \
    set -eux; \
    source /usr/local/lib/gh-dl.sh; \
    export GITHUB_TOKEN="$(cat /run/secrets/github_token 2>/dev/null || echo '')"; \
    source /etc/tool-arch.env; \
    asset="bat-${BAT_VERSION}-${RUST_GNU}.tar.gz"; \
    base="https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}"; \
    gh-dl "${base}/${asset}" /tmp/bat.tar.gz; \
    mkdir -p /tmp/bat-extract; \
    tar -xzf /tmp/bat.tar.gz -C /tmp/bat-extract --strip-components=1; \
    install -m 0755 /tmp/bat-extract/bat /usr/local/bin/bat; \
    rm -rf /tmp/bat-extract /tmp/bat.tar.gz

# renovate: datasource=github-releases depName=sharkdp/fd
ARG FD_VERSION=10.4.2
RUN --mount=type=cache,target=/tmp/tool-cache \
    --mount=type=secret,id=github_token \
    set -eux; \
    source /usr/local/lib/gh-dl.sh; \
    export GITHUB_TOKEN="$(cat /run/secrets/github_token 2>/dev/null || echo '')"; \
    source /etc/tool-arch.env; \
    asset="fd_${FD_VERSION}_${DEB_ARCH}.deb"; \
    base="https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}"; \
    gh-dl "${base}/${asset}" /tmp/fd.deb; \
    dpkg -i /tmp/fd.deb; \
    rm -f /tmp/fd.deb

# renovate: datasource=github-releases depName=junegunn/fzf
ARG FZF_VERSION=0.72.0
RUN --mount=type=cache,target=/tmp/tool-cache \
    --mount=type=secret,id=github_token \
    set -eux; \
    source /usr/local/lib/gh-dl.sh; \
    export GITHUB_TOKEN="$(cat /run/secrets/github_token 2>/dev/null || echo '')"; \
    source /etc/tool-arch.env; \
    asset="fzf-${FZF_VERSION}-${FZF_ARCH}.tar.gz"; \
    base="https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}"; \
    gh-dl "${base}/${asset}" /tmp/fzf.tar.gz; \
    tar -xzf /tmp/fzf.tar.gz -C /usr/local/bin fzf; \
    rm -f /tmp/fzf.tar.gz

# renovate: datasource=github-releases depName=eza-community/eza
ARG EZA_VERSION=0.23.4
RUN --mount=type=cache,target=/tmp/tool-cache \
    --mount=type=secret,id=github_token \
    set -eux; \
    source /usr/local/lib/gh-dl.sh; \
    export GITHUB_TOKEN="$(cat /run/secrets/github_token 2>/dev/null || echo '')"; \
    source /etc/tool-arch.env; \
    asset="eza_${RUST_GNU}.tar.gz"; \
    base="https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}"; \
    gh-dl "${base}/${asset}" /tmp/eza.tar.gz; \
    tar -xzf /tmp/eza.tar.gz -C /tmp; \
    install -m 0755 /tmp/eza /usr/local/bin/eza; \
    rm -rf /tmp/eza /tmp/eza.tar.gz

# renovate: datasource=github-releases depName=bootandy/dust
ARG DUST_VERSION=1.2.4
RUN --mount=type=cache,target=/tmp/tool-cache \
    --mount=type=secret,id=github_token \
    set -eux; \
    source /usr/local/lib/gh-dl.sh; \
    export GITHUB_TOKEN="$(cat /run/secrets/github_token 2>/dev/null || echo '')"; \
    source /etc/tool-arch.env; \
    asset="dust-v${DUST_VERSION}-${RUST_GNU}.tar.gz"; \
    base="https://github.com/bootandy/dust/releases/download/v${DUST_VERSION}"; \
    gh-dl "${base}/${asset}" /tmp/dust.tar.gz; \
    mkdir -p /tmp/dust-extract; \
    tar -xzf /tmp/dust.tar.gz -C /tmp/dust-extract --strip-components=1; \
    install -m 0755 /tmp/dust-extract/dust /usr/local/bin/dust; \
    rm -rf /tmp/dust-extract /tmp/dust.tar.gz

# renovate: datasource=github-releases depName=mikefarah/yq
ARG YQ_VERSION=4.53.2
RUN --mount=type=cache,target=/tmp/tool-cache \
    --mount=type=secret,id=github_token \
    set -eux; \
    source /usr/local/lib/gh-dl.sh; \
    export GITHUB_TOKEN="$(cat /run/secrets/github_token 2>/dev/null || echo '')"; \
    source /etc/tool-arch.env; \
    asset="yq_linux_${GO_ARCH}"; \
    base="https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}"; \
    gh-dl "${base}/${asset}" /usr/local/bin/yq; \
    chmod +x /usr/local/bin/yq

# renovate: datasource=github-releases depName=dandavison/delta
ARG DELTA_VERSION=0.19.2
RUN --mount=type=cache,target=/tmp/tool-cache \
    --mount=type=secret,id=github_token \
    set -eux; \
    source /usr/local/lib/gh-dl.sh; \
    export GITHUB_TOKEN="$(cat /run/secrets/github_token 2>/dev/null || echo '')"; \
    source /etc/tool-arch.env; \
    asset="git-delta_${DELTA_VERSION}_${DEB_ARCH}.deb"; \
    base="https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}"; \
    gh-dl "${base}/${asset}" /tmp/delta.deb; \
    dpkg -i /tmp/delta.deb; \
    rm -f /tmp/delta.deb

# renovate: datasource=github-releases depName=chmln/sd
ARG SD_VERSION=v1.1.0
RUN --mount=type=cache,target=/tmp/tool-cache \
    --mount=type=secret,id=github_token \
    set -eux; \
    source /usr/local/lib/gh-dl.sh; \
    export GITHUB_TOKEN="$(cat /run/secrets/github_token 2>/dev/null || echo '')"; \
    source /etc/tool-arch.env; \
    asset="sd-${SD_VERSION}-${RUST_MUSL}.tar.gz"; \
    base="https://github.com/chmln/sd/releases/download/${SD_VERSION}"; \
    gh-dl "${base}/${asset}" /tmp/sd.tar.gz; \
    mkdir -p /tmp/sd-extract; \
    tar -xzf /tmp/sd.tar.gz -C /tmp/sd-extract --strip-components=1; \
    install -m 0755 /tmp/sd-extract/sd /usr/local/bin/sd; \
    rm -rf /tmp/sd-extract /tmp/sd.tar.gz

# renovate: datasource=github-releases depName=ajeetdsouza/zoxide
ARG ZOXIDE_VERSION=0.9.9
RUN --mount=type=cache,target=/tmp/tool-cache \
    --mount=type=secret,id=github_token \
    set -eux; \
    source /usr/local/lib/gh-dl.sh; \
    export GITHUB_TOKEN="$(cat /run/secrets/github_token 2>/dev/null || echo '')"; \
    source /etc/tool-arch.env; \
    asset="zoxide-${ZOXIDE_VERSION}-${RUST_MUSL}.tar.gz"; \
    base="https://github.com/ajeetdsouza/zoxide/releases/download/v${ZOXIDE_VERSION}"; \
    gh-dl "${base}/${asset}" /tmp/zoxide.tar.gz; \
    tar -xzf /tmp/zoxide.tar.gz -C /tmp; \
    install -m 0755 /tmp/zoxide /usr/local/bin/zoxide; \
    mkdir -p /etc/profile.d; \
    printf '%s\n' 'eval "$(zoxide init bash)"' > /etc/profile.d/zoxide.sh; \
    printf '%s\n' 'eval "$(zoxide init zsh)"' > /etc/profile.d/zoxide.zsh; \
    rm -rf /tmp/zoxide /tmp/zoxide.tar.gz

# renovate: datasource=github-releases depName=sharkdp/hyperfine
ARG HYPERFINE_VERSION=1.20.0
RUN --mount=type=cache,target=/tmp/tool-cache \
    --mount=type=secret,id=github_token \
    set -eux; \
    source /usr/local/lib/gh-dl.sh; \
    export GITHUB_TOKEN="$(cat /run/secrets/github_token 2>/dev/null || echo '')"; \
    source /etc/tool-arch.env; \
    asset="hyperfine_${HYPERFINE_VERSION}_${DEB_ARCH}.deb"; \
    base="https://github.com/sharkdp/hyperfine/releases/download/v${HYPERFINE_VERSION}"; \
    gh-dl "${base}/${asset}" /tmp/hyperfine.deb; \
    dpkg -i /tmp/hyperfine.deb; \
    rm -f /tmp/hyperfine.deb

# renovate: datasource=github-releases depName=ClementTsang/bottom
ARG BOTTOM_VERSION=0.12.3
RUN --mount=type=cache,target=/tmp/tool-cache \
    --mount=type=secret,id=github_token \
    set -eux; \
    source /usr/local/lib/gh-dl.sh; \
    export GITHUB_TOKEN="$(cat /run/secrets/github_token 2>/dev/null || echo '')"; \
    source /etc/tool-arch.env; \
    asset="bottom_${BOTTOM_VERSION}-1_${DEB_ARCH}.deb"; \
    base="https://github.com/ClementTsang/bottom/releases/download/${BOTTOM_VERSION}"; \
    gh-dl "${base}/${asset}" /tmp/bottom.deb; \
    dpkg -i /tmp/bottom.deb; \
    rm -f /tmp/bottom.deb

# ── Shell aliases ──────────────────────────────────────────────────
RUN set -eux; \
    printf '%s\n' \
      "alias ls='eza --icons=auto'" \
      "alias ll='eza -lah --git --icons=auto'" \
      "alias la='eza -la --icons=auto'" \
      "alias cat='bat --paging=never'" \
      "alias du='dust'" \
      "alias top='btm'" \
      >> /etc/bash.bashrc

RUN set -eux; \
    if [ -d /etc/zsh ]; then \
      printf '%s\n' \
        "alias ls='eza --icons=auto'" \
        "alias ll='eza -lah --git --icons=auto'" \
        "alias la='eza -la --icons=auto'" \
        "alias cat='bat --paging=never'" \
        "alias du='dust'" \
        "alias top='btm'" \
        >> /etc/zsh/zshrc; \
    fi

# ── Verify tools ───────────────────────────────────────────────────
RUN set -eux; \
    bash -lc 'source /etc/profile.d/zoxide.sh && zoxide --version'; \
    bat --version; \
    fd --version; \
    fzf --version; \
    eza --version; \
    dust --version; \
    yq --version; \
    delta --version; \
    sd --version; \
    zoxide --version; \
    hyperfine --version; \
    btm --version; \
    gh --version

# ── OpenCode CLI ───────────────────────────────────────────────────
# renovate: datasource=npm depName=opencode-ai
ARG OPENCODE_VERSION=1.14.48
RUN --mount=type=cache,target=/root/.npm \
    set -eux; \
    npm_config_retry=5 npm_config_retry_timeout=30000 \
    npm install -g opencode-ai@${OPENCODE_VERSION}; \
    opencode --version

# ── CodeNomad Server ───────────────────────────────────────────────
# renovate: datasource=npm depName=@neuralnomads/codenomad
ARG CODENOMAD_VERSION=0.15.0
RUN --mount=type=cache,target=/root/.npm \
    set -eux; \
    npm_config_retry=5 npm_config_retry_timeout=30000 \
    npm install -g @neuralnomads/codenomad@${CODENOMAD_VERSION}; \
    npm list -g @neuralnomads/codenomad --depth=0; \
    codenomad --help

# ── Supervisor config ──────────────────────────────────────────────
COPY dockerfiles/ai-workspace/supervisord.conf /etc/supervisor/conf.d/ai-workspace.conf

# Ensure the workspace directory exists and is writable
RUN mkdir -p /workspace && chown -R hermes:hermes /workspace

# Patch the base entrypoint so it defaults to supervisord instead of
# running `hermes "$@"` directly.  This way even if someone launches the
# container with unexpected args (e.g. `gateway run`), supervisor still
# starts and manages both codenomad + hermes-gateway.
RUN sed -i 's|exec hermes "\$@"|exec supervisord -c /etc/supervisor/conf.d/ai-workspace.conf|' /opt/hermes/docker/entrypoint.sh

# ── Runtime ────────────────────────────────────────────────────────
# Keep the hermes entrypoint (handles volume setup, UID remapping, gosu drop)
# Override CMD: entrypoint will detect supervisord as an executable and exec it
# after completing volume setup and privilege drop.
#
# supervisord (-n = nodaemon) spawns:
#   • codenomad  → HTTP :9899 (CodeNomad web UI)
#   • hermes      → gateway (Telegram + other platforms)
EXPOSE 9899

CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
