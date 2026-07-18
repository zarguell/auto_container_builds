FROM docker.io/zarguell/hermes:latest

LABEL maintainer="zarguell"
LABEL description="Hermes Agent + Web UI — all-in-one with CLI tools"

USER root

# Copy hermes-webui source from upstream image
# renovate: datasource=docker depName=ghcr.io/nesquena/hermes-webui
ARG HERMES_WEBUI_TAG=v0.52.41
COPY --from=ghcr.io/nesquena/hermes-webui:${HERMES_WEBUI_TAG} /apptoo /opt/hermes-webui

# WebUI only needs pyyaml + cryptography beyond what agent venv already has
RUN --mount=type=cache,target=/root/.cache/uv \
    uv pip install pyyaml cryptography

# Set defaults matching upstream container conventions
ENV HERMES_WEBUI_HOST=0.0.0.0
ENV HERMES_WEBUI_PORT=8787
ENV HERMES_WEBUI_STATE_DIR=/home/hermes/.hermes/webui
ENV HERMES_WEBUI_DEFAULT_WORKSPACE=/workspace

EXPOSE 8787

# Override agent image entrypoint; start webui by default
ENTRYPOINT []
CMD ["/opt/hermes/.venv/bin/python", "/opt/hermes-webui/server.py"]

# Keep the same runtime user as the base image
USER hermes
