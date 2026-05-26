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

# Placeholder destination works when a specific UDID is not registered with xcodebuild.
echo "SIM_DESTINATION=generic/platform=iOS Simulator" >> "${GITHUB_ENV:?GITHUB_ENV not set}"
echo "Using generic/platform=iOS Simulator (CI deployment target override)"
