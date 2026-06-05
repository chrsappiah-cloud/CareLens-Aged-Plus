#!/usr/bin/env bash
# CareLens Aged+ — E2E tests on a physical iPhone (unit + UI smoke).
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$PROJECT_DIR/Carelens-Aged+.xcodeproj"
SCHEME="Carelens-Aged+"
TIMESTAMP="$(date "+%Y-%m-%d_%H.%M.%S")"
REPORT_DIR="${REPORT_DIR:-$HOME/Desktop/CareLensReports/device}"
XCRESULT="$REPORT_DIR/DeviceE2E_$TIMESTAMP.xcresult"
LOG_FILE="$REPORT_DIR/DeviceE2E_$TIMESTAMP.log"

mkdir -p "$REPORT_DIR"

resolve_device_id() {
  if [ -n "${DEVICE_ID:-}" ]; then
    echo "$DEVICE_ID"
    return
  fi

  local id
  id="$(xcrun devicectl list devices 2>/dev/null \
    | awk '/iPhone/ && /available/ { print $4; exit }' || true)"
  if [ -n "$id" ]; then
    echo "$id"
    return
  fi

  id="$(xcrun xctrace list devices 2>/dev/null \
    | grep -E "iPhone.*\(" \
    | grep -v Simulator \
    | sed -n 's/.*(\([0-9A-F-]\{36\}\)).*/\1/p' \
    | head -1 || true)"
  echo "$id"
}

DEVICE_ID="$(resolve_device_id)"
if [ -z "$DEVICE_ID" ]; then
  echo "ERROR: No connected physical iPhone found."
  echo "Connect your device, unlock it, trust this Mac, and enable Developer Mode."
  exit 1
fi

DESTINATION="platform=iOS,id=$DEVICE_ID"

echo "========================================"
echo " CareLens Aged+ — Physical Device E2E"
echo "========================================"
echo "Device: $DEVICE_ID"
echo "Destination: $DESTINATION"
echo "Report: $XCRESULT"
echo ""
echo "Ensure the iPhone is unlocked before tests start."
echo ""

echo "[1/3] Building for testing on device..."
set -o pipefail
xcodebuild build-for-testing \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  -allowProvisioningUpdates \
  2>&1 | tee "$LOG_FILE" | tail -20

echo ""
echo "[2/3] Running unit + foundations tests on device..."
xcodebuild test-without-building \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  -only-testing:"Carelens-Aged+Tests" \
  -resultBundlePath "$XCRESULT" \
  -allowProvisioningUpdates \
  2>&1 | tee -a "$LOG_FILE"

echo ""
echo "[3/3] Running UI smoke tests on device..."
xcodebuild test-without-building \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  -only-testing:"Carelens-Aged+UITests/Carelens_Aged_UITests/testLoginScreenAppears" \
  -only-testing:"Carelens-Aged+UITests/Carelens_Aged_UITests/testDarkThemeLoginControlsVisible" \
  -only-testing:"Carelens-Aged+UITests/Carelens_Aged_UITests/testAdminLoginFlow" \
  -allowProvisioningUpdates \
  2>&1 | tee -a "$LOG_FILE"

echo ""
echo "STATUS: Physical device E2E complete"
echo "Results: $XCRESULT"
echo "Log: $LOG_FILE"
