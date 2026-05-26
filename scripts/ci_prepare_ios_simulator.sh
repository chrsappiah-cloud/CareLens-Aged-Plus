#!/usr/bin/env bash
# Prepare iOS Simulator testing on GitHub Actions (runners often lack iOS 26.x runtimes).
set -euo pipefail

echo "Downloading iOS platform (if needed)..."
xcodebuild -downloadPlatform iOS || true

xcrun simctl list devices available > /tmp/sim-devices.txt
DEVICE_ID=$(grep -E "iPhone" /tmp/sim-devices.txt | grep -v "unavailable" | head -1 | grep -oE '[A-F0-9-]{36}' | head -1 || true)

if [ -n "${DEVICE_ID:-}" ]; then
  echo "Booting simulator $DEVICE_ID"
  xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
  xcrun simctl bootstatus "$DEVICE_ID" -b 2>/dev/null || true
fi

echo "SIM_DESTINATION=generic/platform=iOS Simulator" >> "${GITHUB_ENV:?GITHUB_ENV not set}"

if [ -n "${DEVICE_ID:-}" ]; then
  echo "SIM_TEST_DESTINATION=platform=iOS Simulator,id=${DEVICE_ID}" >> "${GITHUB_ENV}"
  echo "Build: generic/platform=iOS Simulator | Tests: id=${DEVICE_ID}"
else
  echo "SIM_TEST_DESTINATION=generic/platform=iOS Simulator" >> "${GITHUB_ENV}"
  echo "Warning: no iPhone simulator UDID; tests may fail"
fi
