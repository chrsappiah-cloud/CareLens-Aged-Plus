#!/usr/bin/env bash
# Prepare a bootable iPhone simulator on GitHub Actions macOS runners.
set -euo pipefail

echo "Downloading iOS platform (if needed)..."
xcodebuild -downloadPlatform iOS

xcrun simctl list devices available > /tmp/sim-devices.txt
DEVICE_ID=$(grep -E "iPhone" /tmp/sim-devices.txt | grep -v "unavailable" | head -1 | grep -oE '[A-F0-9-]{36}' | head -1 || true)

if [ -z "${DEVICE_ID:-}" ]; then
  echo "No iPhone simulator found:"
  cat /tmp/sim-devices.txt
  exit 1
fi

echo "Booting simulator $DEVICE_ID"
xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
xcrun simctl bootstatus "$DEVICE_ID" -b

DESTINATION="platform=iOS Simulator,id=${DEVICE_ID}"
echo "SIM_DESTINATION=${DESTINATION}" >> "${GITHUB_ENV:?GITHUB_ENV not set}"
echo "Using ${DESTINATION}"
