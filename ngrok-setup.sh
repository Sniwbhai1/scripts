#!/bin/bash
# === SNIW NGROK SSH AUTO SETUP ===

set -euo pipefail

LOG_FILE="/tmp/ngrok.log"

clear
echo "===================================================="
echo "   ███████╗███╗   ██╗██╗██╗    ██╗"
echo "   ██╔════╝████╗  ██║██║██║    ██║"
echo "   ███████╗██╔██╗ ██║██║██║ █╗ ██║"
echo "   ╚════██║██║╚██╗██║██║██║███╗██║"
echo "   ███████║██║ ╚████║██║╚███╔███╔╝"
echo "   ╚══════╝╚═╝  ╚═══╝╚═╝ ╚══╝╚══╝ "
echo "===================================================="
echo ""

# make sure ngrok is installed
if ! command -v ngrok >/dev/null 2>&1; then
    echo "[+] Installing ngrok..."
    apt update -y >/dev/null
    apt install -y unzip wget >/dev/null
    wget -q -O /tmp/ngrok.zip https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
    unzip -o /tmp/ngrok.zip -d /usr/local/bin >/dev/null
    chmod +x /usr/local/bin/ngrok
    rm -f /tmp/ngrok.zip
    echo "[✓] ngrok installed!"
fi

# ask for auth token
read -p "🔑 Enter your ngrok authtoken: " TOKEN
ngrok config add-authtoken "$TOKEN"

# cleanup and run
rm -f "$LOG_FILE"
touch "$LOG_FILE"
chmod 666 "$LOG_FILE"

pkill -f ngrok || true
nohup ngrok tcp 22 --log=stdout > "$LOG_FILE" 2>&1 &

echo "[+] Starting ngrok tunnel..."
sleep 5

ADDR=$(grep -m1 -oE 'url=tcp://[^ ]+' "$LOG_FILE" | sed 's/url=tcp:\/\///')
if [ -n "$ADDR" ]; then
    echo ""
    echo "✅ Tunnel live!"
    echo "SSH using:"
    echo "ssh root@${ADDR%:*} -p ${ADDR##*:}"
else
    echo "❌ Could not find tunnel address. Check /tmp/ngrok.log"
fi
