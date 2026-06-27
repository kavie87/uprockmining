#!/bin/bash
set -e

echo "Stopping UpRock service and old VNC sessions..."
systemctl stop uprock || true
pkill -f uprock-mining || true
pkill -f x11vnc || true
pkill -f websockify || true
pkill -f "Xvfb :98" || true
rm -f /tmp/.X98-lock

echo "Starting temporary display :98..."
Xvfb :98 -screen 0 1280x720x24 -nolisten tcp &
sleep 3

echo "Starting UpRock GUI on :98..."
DISPLAY=:98 uprock-mining &

echo "Starting VNC/noVNC..."
x11vnc -display :98 -forever -shared -nopw -rfbport 5900 -noxdamage &
websockify --web=/usr/share/novnc 6080 localhost:5900 &

IP=$(hostname -I | awk '{print $1}')

echo
echo "Open:"
echo "http://$IP:6080/vnc.html"
echo
echo "When finished, run:"
echo "./stop-uprock-vnc.sh"
