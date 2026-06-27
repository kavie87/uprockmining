#!/bin/bash
set -e

UPROCK_URL="https://edge.uprock.com/v1/app-download/UpRock-Mining-v0.0.37.deb"

echo "Installing dependencies..."
apt update
apt install -y \
  wget \
  xvfb \
  dbus-x11 \
  chromium \
  x11vnc \
  novnc \
  websockify

echo "Downloading UpRock..."
cd /root
wget -O UpRock-Mining.deb "$UPROCK_URL"

echo "Installing UpRock..."
apt install -y ./UpRock-Mining.deb

echo "Creating startup script..."
cat > /usr/local/bin/start-uprock.sh <<'EOF'
#!/bin/bash
set -e

export HOME=/root
export DISPLAY=:99

rm -f /tmp/.X99-lock

Xvfb :99 -screen 0 1280x720x24 -nolisten tcp &
sleep 5

exec /usr/bin/uprock-mining -windowless
EOF

chmod +x /usr/local/bin/start-uprock.sh

echo "Creating systemd service..."
cat > /etc/systemd/system/uprock.service <<'EOF'
[Unit]
Description=UpRock Mining Headless
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
Environment=HOME=/root
ExecStart=/usr/local/bin/start-uprock.sh
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now uprock

echo "Done."
echo "Check status with:"
echo "  systemctl status uprock"
echo "  journalctl -u uprock -f"
