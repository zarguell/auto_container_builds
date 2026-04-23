FROM docker.io/nousresearch/hermes-agent:v2026.4.16@sha256:14ba9a26cf2d498ea773f1825326c404795ec4cb436a9479d22b7a345396c370

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DEBIAN_FRONTEND=noninteractive

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
    && rm -rf /var/lib/apt/lists/*

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

# renovate: datasource=github-releases depName=cli/cli
ARG GH_VERSION=2.91.0
# TODO: Consider adding checksum verification for other tools (bat, fd, fzf, eza, dust, yq, delta, sd, zoxide, hyperfine, bottom)
# - gh CLI has dedicated checksums.txt files in releases
# - Other tools expose SHA256 via GitHub API: curl -sL "https://api.github.com/repos/OWNER/REPO/releases/latest" | jq '.assets[] | select(.name | test("deb$")) | .name + " " + .digest'
# - Tradeoff: API-based verification adds complexity but improves security over HTTPS-only
# - Tar.gz extractions would need additional handling to verify binaries inside archives
RUN set -eux; \
    source /etc/tool-arch.env; \
    asset="gh_${GH_VERSION}_linux_${DEB_ARCH}.deb"; \
    base="https://github.com/cli/cli/releases/download/v${GH_VERSION}"; \
    curl -fsSL "${base}/${asset}" -o "/tmp/${asset}"; \
    curl -fsSL "${base}/gh_${GH_VERSION}_checksums.txt" -o /tmp/gh_checksums.txt; \
    cd /tmp; \
    grep " ${asset}$" gh_checksums.txt | sha256sum -c -; \
    dpkg -i "/tmp/${asset}"; \
    rm -f "/tmp/${asset}" /tmp/gh_checksums.txt

# renovate: datasource=github-releases depName=sharkdp/bat
ARG BAT_VERSION=v0.26.1
RUN set -eux; \
    source /etc/tool-arch.env; \
    asset="bat-${BAT_VERSION}-${RUST_GNU}.tar.gz"; \
    base="https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}"; \
    curl -fsSL "${base}/${asset}" -o /tmp/bat.tar.gz; \
    mkdir -p /tmp/bat-extract; \
    tar -xzf /tmp/bat.tar.gz -C /tmp/bat-extract --strip-components=1; \
    install -m 0755 /tmp/bat-extract/bat /usr/local/bin/bat; \
    rm -rf /tmp/bat-extract /tmp/bat.tar.gz

# renovate: datasource=github-releases depName=sharkdp/fd
ARG FD_VERSION=9.0.0
RUN set -eux; \
    source /etc/tool-arch.env; \
    asset="fd_${FD_VERSION}_${DEB_ARCH}.deb"; \
    base="https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}"; \
    curl -fsSL "${base}/${asset}" -o /tmp/fd.deb; \
    dpkg -i /tmp/fd.deb; \
    rm -f /tmp/fd.deb

# renovate: datasource=github-releases depName=junegunn/fzf
ARG FZF_VERSION=0.70.0
RUN set -eux; \
    source /etc/tool-arch.env; \
    asset="fzf-${FZF_VERSION}-${FZF_ARCH}.tar.gz"; \
    base="https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}"; \
    curl -fsSL "${base}/${asset}" -o /tmp/fzf.tar.gz; \
    tar -xzf /tmp/fzf.tar.gz -C /usr/local/bin fzf; \
    rm -f /tmp/fzf.tar.gz

# renovate: datasource=github-releases depName=eza-community/eza
ARG EZA_VERSION=0.23.4
RUN set -eux; \
    source /etc/tool-arch.env; \
    asset="eza_${RUST_GNU}.tar.gz"; \
    base="https://github.com/eza-community/eza/releases/download/v${EZA_VERSION}"; \
    curl -fsSL "${base}/${asset}" -o /tmp/eza.tar.gz; \
    tar -xzf /tmp/eza.tar.gz -C /tmp; \
    install -m 0755 /tmp/eza /usr/local/bin/eza; \
    rm -rf /tmp/eza /tmp/eza.tar.gz

# renovate: datasource=github-releases depName=bootandy/dust
ARG DUST_VERSION=1.2.4
RUN set -eux; \
    source /etc/tool-arch.env; \
    asset="dust-v${DUST_VERSION}-${RUST_GNU}.tar.gz"; \
    base="https://github.com/bootandy/dust/releases/download/v${DUST_VERSION}"; \
    curl -fsSL "${base}/${asset}" -o /tmp/dust.tar.gz; \
    mkdir -p /tmp/dust-extract; \
    tar -xzf /tmp/dust.tar.gz -C /tmp/dust-extract --strip-components=1; \
    install -m 0755 /tmp/dust-extract/dust /usr/local/bin/dust; \
    rm -rf /tmp/dust-extract /tmp/dust.tar.gz

# renovate: datasource=github-releases depName=mikefarah/yq
ARG YQ_VERSION=4.27.2
RUN set -eux; \
    source /etc/tool-arch.env; \
    asset="yq_linux_${GO_ARCH}"; \
    base="https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}"; \
    curl -fsSL "${base}/${asset}" -o /usr/local/bin/yq; \
    chmod +x /usr/local/bin/yq

# renovate: datasource=github-releases depName=dandavison/delta
ARG DELTA_VERSION=0.19.2
RUN set -eux; \
    source /etc/tool-arch.env; \
    asset="git-delta_${DELTA_VERSION}_${DEB_ARCH}.deb"; \
    base="https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}"; \
    curl -fsSL "${base}/${asset}" -o /tmp/delta.deb; \
    dpkg -i /tmp/delta.deb; \
    rm -f /tmp/delta.deb

# renovate: datasource=github-releases depName=chmln/sd
ARG SD_VERSION=v1.1.0
RUN set -eux; \
    source /etc/tool-arch.env; \
    asset="sd-${SD_VERSION}-${RUST_MUSL}.tar.gz"; \
    base="https://github.com/chmln/sd/releases/download/${SD_VERSION}"; \
    curl -fsSL "${base}/${asset}" -o /tmp/sd.tar.gz; \
    mkdir -p /tmp/sd-extract; \
    tar -xzf /tmp/sd.tar.gz -C /tmp/sd-extract --strip-components=1; \
    install -m 0755 /tmp/sd-extract/sd /usr/local/bin/sd; \
    rm -rf /tmp/sd-extract /tmp/sd.tar.gz

# renovate: datasource=github-releases depName=ajeetdsouza/zoxide
ARG ZOXIDE_VERSION=0.9.9
RUN set -eux; \
    source /etc/tool-arch.env; \
    asset="zoxide-${ZOXIDE_VERSION}-${RUST_MUSL}.tar.gz"; \
    base="https://github.com/ajeetdsouza/zoxide/releases/download/v${ZOXIDE_VERSION}"; \
    curl -fsSL "${base}/${asset}" -o /tmp/zoxide.tar.gz; \
    tar -xzf /tmp/zoxide.tar.gz -C /tmp; \
    install -m 0755 /tmp/zoxide /usr/local/bin/zoxide; \
    mkdir -p /etc/profile.d; \
    printf '%s\n' 'eval "$(zoxide init bash)"' > /etc/profile.d/zoxide.sh; \
    printf '%s\n' 'eval "$(zoxide init zsh)"' > /etc/profile.d/zoxide.zsh; \
    rm -rf /tmp/zoxide /tmp/zoxide.tar.gz

# renovate: datasource=github-releases depName=sharkdp/hyperfine
ARG HYPERFINE_VERSION=1.19.0
RUN set -eux; \
    source /etc/tool-arch.env; \
    asset="hyperfine_${HYPERFINE_VERSION}_${DEB_ARCH}.deb"; \
    base="https://github.com/sharkdp/hyperfine/releases/download/v${HYPERFINE_VERSION}"; \
    curl -fsSL "${base}/${asset}" -o /tmp/hyperfine.deb; \
    dpkg -i /tmp/hyperfine.deb; \
    rm -f /tmp/hyperfine.deb

# renovate: datasource=github-releases depName=ClementTsang/bottom
ARG BOTTOM_VERSION=0.12.3
RUN set -eux; \
    source /etc/tool-arch.env; \
    asset="bottom_${BOTTOM_VERSION}-1_${DEB_ARCH}.deb"; \
    base="https://github.com/ClementTsang/bottom/releases/download/${BOTTOM_VERSION}"; \
    curl -fsSL "${base}/${asset}" -o /tmp/bottom.deb; \
    dpkg -i /tmp/bottom.deb; \
    rm -f /tmp/bottom.deb

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

# renovate: datasource=npm depName=opencode-ai
ARG OPENCODE_VERSION=1.4.7
RUN set -eux; \
    npm install -g opencode-ai@${OPENCODE_VERSION}; \
    opencode --version

USER hermes
