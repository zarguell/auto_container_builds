#!/bin/bash
set -euo pipefail

# dev-box entrypoint:
#   (no args) | canvas | agent-canvas  → start Agent Canvas (full stack, :8000)
#   shell                              → raw interactive dev shell
#   anything else                      → exec the args directly (pi, pi-acp, bash -c ...)
#
# Runs as root: remaps the `coder` user to PUID/PGID (linuxserver-style),
# chowns the mounted workspace/state dirs, then drops to coder via setpriv.
# Passwordless sudo remains available inside the container.

PUID="${PUID:-1000}"
PGID="${PGID:-1000}"

if [ "$(id -u)" = "0" ]; then
  CURRENT_UID="$(id -u coder)"
  CURRENT_GID="$(id -g coder)"
  if [ "${PUID}" != "${CURRENT_UID}" ] || [ "${PGID}" != "${CURRENT_GID}" ]; then
    # Fast remap (fixuid-style): rewrite coder's uid/gid in passwd/group,
    # then chown. usermod would work but scans the whole filesystem for
    # files owned by the old uid (~2.5 min on this image). Keeping the
    # `coder` name mapped means sudo's `coder ALL=(ALL)` rule still applies.
    echo "dev-box: remapping coder to ${PUID}:${PGID} (one-time chown, ~30s)"
    sed -i "s/^\\(coder:x:\\)[0-9]*:[0-9]*:/\\1${PUID}:${PGID}:/" /etc/passwd
    sed -i "s/^\\(coder:x:\\)[0-9]*:/\\1${PGID}:/" /etc/group
    # Parallel chown of the baked uv cache (≈94k files); sequential
    # chown -R takes ~80s under Docker Desktop's overlayfs.
    find /home/coder /opt/uv-cache /opt/uv-python -print0 | xargs -0 -P "$(nproc)" -n 100 chown -h coder:coder
  fi
  # Mounted workspace + state dirs must be writable by the dev user.
  # Ownership guard skips the scan when the mount already matches.
  for d in /projects /home/coder/.openhands /home/coder/.pi /home/coder/.omp; do
    if [ -d "${d}" ] && [ "$(stat -c %u "${d}" 2>/dev/null || echo -1)" != "${PUID}" ]; then
      chown -R coder:coder "${d}"
    fi
  done
  # Seed a fresh/empty home mount from the small baked skeleton (shell rc
  # files, empty state dirs). The heavy uv wheel cache lives at /opt/uv-cache
  # in the image layer, so seeding stays instant.
  if [ -z "$(ls -A /home/coder 2>/dev/null)" ]; then
    echo "dev-box: seeding fresh home from /opt/home-skel"
    cp -a /opt/home-skel/. /home/coder/
    chown -R coder:coder /home/coder
  fi
fi

case "${1:-}" in
  "" | canvas | agent-canvas)
    shift || true
    if [ "$(id -u)" = "0" ]; then
      exec env HOME=/home/coder setpriv --reuid=coder --regid=coder --init-groups agent-canvas "$@"
    else
      exec agent-canvas "$@"
    fi
    ;;
  shell)
    shift
    if [ "$(id -u)" = "0" ]; then
      exec env HOME=/home/coder setpriv --reuid=coder --regid=coder --init-groups bash "$@"
    else
      exec bash "$@"
    fi
    ;;
  *)
    if [ "$(id -u)" = "0" ]; then
      exec env HOME=/home/coder setpriv --reuid=coder --regid=coder --init-groups "$@"
    else
      exec "$@"
    fi
    ;;
esac
