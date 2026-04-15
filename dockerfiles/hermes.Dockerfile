FROM nousresearch/hermes-agent:fa9237f9ee132a25782e5e9597c6af3f7b7b1dbe9fa520af9061e0c56243625c

USER root

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

# Install GitHub CLI
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
       | gpg --dearmor -o /etc/apt/keyrings/githubcli.gpg \
    && chmod go+r /etc/apt/keyrings/githubcli.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli.gpg] https://cli.github.com/packages stable main" \
       > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends gh \
    && rm -rf /var/lib/apt/lists/*
