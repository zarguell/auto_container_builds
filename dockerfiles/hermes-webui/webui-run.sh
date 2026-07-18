#!/command/with-contenv sh
export HOME=/home/hermes
cd /opt/hermes-webui
exec s6-setuidgid hermes /opt/hermes/.venv/bin/python /opt/hermes-webui/server.py
