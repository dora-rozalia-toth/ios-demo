#!/bin/bash
# Capture the app and ensure the output is upright landscape (wider than tall).
SIM="${SIM:-iPad Pro 13-inch (M5)}"
OUT="${1:-_shots/shot.png}"
mkdir -p "$(dirname "$OUT")"
xcrun simctl io "$SIM" screenshot "$OUT" >/dev/null 2>&1
W=$(sips -g pixelWidth "$OUT" 2>/dev/null | awk '/pixelWidth/{print $2}')
H=$(sips -g pixelHeight "$OUT" 2>/dev/null | awk '/pixelHeight/{print $2}')
if [ "$H" -gt "$W" ]; then
  sips -r 270 "$OUT" >/dev/null 2>&1   # portrait framebuffer -> rotate to upright landscape
fi
sips -g pixelWidth -g pixelHeight "$OUT" 2>/dev/null | grep pixel
