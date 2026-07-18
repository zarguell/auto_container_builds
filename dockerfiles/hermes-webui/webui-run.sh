#!/command/with-contenv sh
export HOME=/home/hermes
cd /opt/hermes-webui
if [ "$(id -u)" = 0 ]; then
    exec s6-setuidgid hermes /opt/hermes/.venv/bin/python /opt/hermes-webui/server.py
else
    exec /opt/hermes/.venv/bin/python /opt/hermes-webui/server.py
fi
