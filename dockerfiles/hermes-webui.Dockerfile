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

# Add web UI as an s6-supervised service so the gateway, dashboard, and web UI
# all run in one container. The base image's ENTRYPOINT /init is preserved.
COPY dockerfiles/hermes-webui/webui-run.sh /etc/s6-overlay/s6-rc.d/hermes-webui/run
COPY dockerfiles/hermes-webui/webui-type /etc/s6-overlay/s6-rc.d/hermes-webui/type
RUN touch /etc/s6-overlay/s6-rc.d/user2/contents.d/hermes-webui

EXPOSE 8787

USER hermes
