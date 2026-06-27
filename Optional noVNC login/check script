#!/bin/bash
set -e

x11vnc \
  -display :99 \
  -forever \
  -shared \
  -nopw \
  -rfbport 5900 \
  -noxdamage &

websockify \
  --web=/usr/share/novnc \
  6080 \
  localhost:5900 &

echo "Open:"
echo "http://DEVICE-IP:6080/vnc.html"
