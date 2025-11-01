#!/bin/bash
# VPS Keep Alive Installer by YourName

set -e

echo "🔧 Installing VPS Keep Alive script..."

cat <<'EOF' > /usr/local/bin/keepalive.sh
#!/bin/bash
while true; do
  curl -s https://google.com > /dev/null 2>&1
  echo "$(date): VPS is alive" >> /var/log/keepalive.log
  sleep 300
done
EOF

chmod +x /usr/local/bin/keepalive.sh

cat <<'EOF' > /etc/systemd/system/keepalive.service
[Unit]
Description=VPS Keep Alive Script
After=network.target

[Service]
ExecStart=/usr/local/bin/keepalive.sh
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now keepalive.service

echo "✅ KeepAlive service installed and running!"
systemctl status keepalive.service --no-pager
