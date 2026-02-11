# syntax=docker/dockerfile:1

# Use Ubuntu base
FROM ubuntu:24.04

# Build arguments for version control
# renovate: datasource=github-tags depName=python/cpython
ARG PYTHON_VERSION_LATEST=3.13.9
# renovate: datasource=github-tags depName=python/cpython
ARG PYTHON_VERSION_COMPAT=3.11.14
# renovate: datasource=node-version depName=node
ARG NODE_VERSION=24.13.1
# renovate: datasource=github-releases depName=nvm-sh/nvm
ARG NVM_VERSION=0.40.4
# renovate: datasource=github-releases depName=pyenv/pyenv
ARG PYENV_GIT_TAG=v2.6.13

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    ca-certificates \
    gnupg \
    lsb-release \
    jq \
    unzip \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash -u 1001 devuser

# Install pyenv system-wide
ENV PYENV_ROOT="/opt/pyenv"
ENV PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"
RUN git clone --branch ${PYENV_GIT_TAG} https://github.com/pyenv/pyenv.git $PYENV_ROOT && \
    chown -R devuser:devuser $PYENV_ROOT

# Switch to non-root user
USER devuser

# Install both Python versions with BuildKit cache mount
RUN --mount=type=cache,target=/opt/pyenv/cache,uid=1001,gid=1001 \
    --mount=type=cache,target=/tmp/python-build,uid=1001,gid=1001 \
    pyenv install ${PYTHON_VERSION_COMPAT} && \
    pyenv install ${PYTHON_VERSION_LATEST} && \
    pyenv global ${PYTHON_VERSION_LATEST} ${PYTHON_VERSION_COMPAT} && \
    pyenv rehash

# Install nvm with version from build arg
ENV NVM_DIR="/home/devuser/.nvm"
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash

# Install Node.js using build arg and set as default
RUN bash -c "source $NVM_DIR/nvm.sh && nvm install ${NODE_VERSION} && nvm alias default ${NODE_VERSION} && nvm use default"

# Set environment variables using build args
ENV NODE_VERSION=${NODE_VERSION}
ENV PYTHON_VERSION=${PYTHON_VERSION_LATEST}
ENV PATH="$NVM_DIR/versions/node/v${NODE_VERSION}/bin:$PATH"

# Set Python path for node-gyp via environment variable
ENV npm_config_python="${PYENV_ROOT}/versions/${PYTHON_VERSION_COMPAT}/bin/python3"

# Install Claude CLI and UI
RUN bash -c "source $NVM_DIR/nvm.sh && npm install -g @anthropic-ai/claude-code @siteboon/claude-code-ui"

# Install Cursor CLI
RUN curl https://cursor.com/install -fsS | bash

# Configure Git credential caching (7 days)
RUN git config --global credential.helper "cache --timeout=604800"

# Set up PATH for user
ENV PATH="/home/devuser/.local/bin:$PATH"

# Create workspace directory
USER root
RUN mkdir -p /workspace && chown devuser:devuser /workspace

# Create entrypoint script
COPY --chown=root:root entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod 755 /usr/local/bin/entrypoint.sh

# Add healthcheck script
COPY --chown=root:root healthcheck.js /usr/local/bin/healthcheck.js
RUN chmod 755 /usr/local/bin/healthcheck.js

# Switch back to non-root user
USER devuser
WORKDIR /workspace

# Add nvm initialization to bashrc for interactive shells
RUN echo 'export NVM_DIR="$HOME/.nvm"' >> /home/devuser/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /home/devuser/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> /home/devuser/.bashrc

# Add metadata labels with versions
LABEL maintainer="zarguell@github"
LABEL version="1.0.0"
LABEL description="Claude Code and Cursor Web UI dev container"
LABEL python.version="${PYTHON_VERSION_LATEST}"
LABEL python.compat.version="${PYTHON_VERSION_COMPAT}"
LABEL node.version="${NODE_VERSION}"

# Expose UI port
EXPOSE 3001

# Add healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD node /usr/local/bin/healthcheck.js

# Use entrypoint for startup logic
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["npx", "@siteboon/claude-code-ui"]
