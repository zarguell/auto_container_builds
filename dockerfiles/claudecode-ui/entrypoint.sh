#!/bin/bash
set -e

# Source nvm for non-interactive shells
export NVM_DIR="/home/devuser/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Execute the command passed to the container
exec "$@"
