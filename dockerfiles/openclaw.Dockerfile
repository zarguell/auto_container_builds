# ==========================================
# STAGE 1: Builder (Standard OpenClaw Logic)
# ==========================================
FROM node:22-bookworm AS builder

# Install Bun (required for build scripts)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

RUN corepack enable
WORKDIR /app

# Set to CI to avoid prompts
ENV CI=true

# Copy dependency manifests first for caching
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./
COPY ui/package.json ./ui/package.json
COPY patches ./patches
COPY scripts ./scripts

# Install dependencies (requires network)
RUN pnpm install --frozen-lockfile

# Copy source and build
COPY . .

# Install memory-core dependencies
RUN cd /extensions/memory-core && pnpm install

RUN OPENCLAW_A2UI_SKIP_MISSING=1 pnpm build
ENV OPENCLAW_PREFER_PNPM=1
RUN pnpm ui:build

# Prune dev dependencies to keep the copy small
RUN pnpm prune --prod

# ==========================================
# STAGE 2: Secure Runtime
# ==========================================
# Start with the official Node image
FROM node:22-bookworm-slim

# 1. Install Python + Tools
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    ca-certificates \
    jq \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Tools (uv, pnpm)
RUN npm install -g pnpm
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# 3. Setup Non-Root User
#    The official node image already creates a user named 'node' (uid 1000).
#    We just configure the directory.
WORKDIR /app
RUN chown node:node /app

# 4. Copy Compiled App from Builder Stage
COPY --from=builder --chown=node:node /app/package.json ./
COPY --from=builder --chown=node:node /app/node_modules ./node_modules
COPY --from=builder --chown=node:node /app/dist ./dist

# UI Copy
COPY --from=builder --chown=node:node /app/ui ./ui
RUN rm -rf ./ui/src ./ui/node_modules

# 5. Runtime Config
ENV NODE_ENV=production
USER node

# 6. Entrypoint
CMD ["node", "dist/index.js", "gateway", "--allow-unconfigured"]
