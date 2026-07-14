#!/bin/bash
set -e

# Start pi-web-sessiond in background
echo "Starting pi-web-sessiond..."
pi-web-sessiond &
SESSIOND_PID=$!

# Give the session daemon a moment to initialise
sleep 2

# Start pi-web-server in foreground (signals forwarded by bash)
echo "Starting pi-web-server on ${PI_WEB_HOST}:${PI_WEB_PORT}..."
PI_WEB_HOST="${PI_WEB_HOST}" PI_WEB_PORT="${PI_WEB_PORT}" exec pi-web-server
