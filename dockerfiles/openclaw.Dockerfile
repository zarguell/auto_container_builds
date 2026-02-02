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
RUN OPENCLAW_A2UI_SKIP_MISSING=1 pnpm build
ENV OPENCLAW_PREFER_PNPM=1
RUN pnpm ui:build

# Prune dev dependencies to keep the copy small
RUN pnpm prune --prod

# ==========================================
# STAGE 2: Secure Runtime
# ==========================================
FROM python:3.14-slim-bookworm

# 1. Install Runtime Dependencies + Your Tools
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    jq \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Install pnpm globally
RUN npm install -g pnpm

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

# 2. Setup Non-Root User
RUN useradd -m -s /bin/bash -u 1000 node
WORKDIR /app

# 3. Copy Compiled App from Builder Stage
COPY --from=builder --chown=node:node /app/package.json ./
COPY --from=builder --chown=node:node /app/node_modules ./node_modules
COPY --from=builder --chown=node:node /app/dist ./dist

# --- FIX: ROBUST UI COPY ---
# We copy the 'ui' folder from builder to catch whatever artifacts were created.
COPY --from=builder --chown=node:node /app/ui ./ui
# We delete the heavy source code and dev modules to keep the image slim.
# This leaves behind only the build outputs (dist/build) and package configs.
RUN rm -rf ./ui/src ./ui/node_modules

# 4. Hardening & Environment
ENV NODE_ENV=production

# 5. Switch to non-root (Fixed typo 'SER' -> 'USER')
USER node

# 6. Define Entrypoint
CMD ["node", "dist/index.js", "gateway", "--allow-unconfigured"]

