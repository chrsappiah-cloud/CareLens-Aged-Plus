#!/usr/bin/env bash
# CareLens Aged+ — systematic unit/function E2E on a physical iPhone.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT="$PROJECT_DIR/Carelens-Aged+.xcodeproj"
SCHEME="Carelens-Aged+"
TARGET="Carelens-Aged+Tests"
TIMESTAMP="$(date "+%Y-%m-%d_%H.%M.%S")"
REPORT_DIR="${REPORT_DIR:-$HOME/Desktop/CareLensReports/device}"
XCRESULT="$REPORT_DIR/DeviceSystematic_$TIMESTAMP.xcresult"
LOG_FILE="$REPORT_DIR/DeviceSystematic_$TIMESTAMP.log"
SUMMARY_FILE="$REPORT_DIR/DeviceSystematic_$TIMESTAMP.summary.txt"

mkdir -p "$REPORT_DIR"

resolve_device_id() {
  if [ -n "${DEVICE_ID:-}" ]; then
    echo "$DEVICE_ID"
    return
  fi

  local id
  id="$(xcrun xctrace list devices 2>/dev/null \
    | grep -E "iPhone.*\(" \
    | grep -v Simulator \
    | grep -v Offline \
    | sed -n 's/.*(\([0-9A-F-]\{36\}\)).*/\1/p' \
    | head -1 || true)"
  if [ -n "$id" ]; then
    echo "$id"
    return
  fi

  xcrun devicectl list devices 2>/dev/null \
    | awk '/iPhone/ && /available/ { print $4; exit }' || true
}

run_phase() {
  local name="$1"
  shift
  local -a tests=("$@")

  echo ""
  echo "---- $name ----"
  {
    echo "PHASE: $name"
    for test_id in "${tests[@]}"; do
      echo "  - $test_id"
    done
  } | tee -a "$SUMMARY_FILE"

  local args=()
  for test_id in "${tests[@]}"; do
    args+=("-only-testing:${test_id}")
  done

  if ! xcodebuild test-without-building \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    "${args[@]}" \
    -allowProvisioningUpdates \
    2>&1 | tee -a "$LOG_FILE"; then
    echo "FAILED: $name" | tee -a "$SUMMARY_FILE"
    return 1
  fi

  echo "PASSED: $name" | tee -a "$SUMMARY_FILE"
}

DEVICE_ID="$(resolve_device_id)"
if [ -z "$DEVICE_ID" ]; then
  echo "ERROR: No connected physical iPhone found."
  echo "Connect your device, unlock it, trust this Mac, and enable Developer Mode."
  exit 1
fi

DESTINATION="platform=iOS,id=$DEVICE_ID"

{
  echo "CareLens Aged+ — Systematic Device E2E"
  echo "Timestamp: $TIMESTAMP"
  echo "Device: $DEVICE_ID"
  echo "Destination: $DESTINATION"
  echo "Log: $LOG_FILE"
  echo "Results: $XCRESULT"
} | tee "$SUMMARY_FILE"

echo "Ensure the iPhone is unlocked before tests start."

echo "[build] Building for testing on device..."
set -o pipefail
xcodebuild build-for-testing \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  -allowProvisioningUpdates \
  2>&1 | tee "$LOG_FILE" | tail -15

FAILED=0

run_phase "1. Enum units" \
  "$TARGET/E2ESubscriptionTierTests" \
  "$TARGET/E2EAppFeatureTests" \
  "$TARGET/E2EUserRoleTests" \
  "$TARGET/E2EAssessmentStatusTests" \
  "$TARGET/E2EMonitoringEventTypeTests" \
  "$TARGET/E2ENeuroWatchBandTests" \
  "$TARGET/E2ESubscriptionProductTests" \
  "$TARGET/E2EReportTypeTests" \
  "$TARGET/E2ECKZoneNameTests" \
  "$TARGET/E2ESyncModelTests" \
  || FAILED=1

run_phase "2. Model units" \
  "$TARGET/ClientProfileTests" \
  "$TARGET/AssessmentSessionTests" \
  "$TARGET/AssessmentSectionTests" \
  "$TARGET/CarePlanTests" \
  "$TARGET/MonitoringEventTests" \
  || FAILED=1

run_phase "3. Service units" \
  "$TARGET/AuthenticationServiceTests" \
  "$TARGET/E2ESubscriptionMgrTests" \
  "$TARGET/E2ENeuroWatchEngineTests" \
  "$TARGET/E2EHealthAPIServiceTests" \
  "$TARGET/E2ENetworkMiddlewareTests" \
  || FAILED=1

run_phase "4. Sync units" \
  "$TARGET/E2ESupabasePrimaryServiceTests" \
  "$TARGET/E2ECloudflareBackupServiceTests" \
  "$TARGET/E2EDataSyncEngineTests" \
  "$TARGET/E2EApplePaySubscriptionTests" \
  || FAILED=1

run_phase "5. Report & data layer" \
  "$TARGET/ReportServiceTests" \
  "$TARGET/AppEnvironmentTests" \
  "$TARGET/RepositoriesProtocolTests" \
  "$TARGET/ThemeUnitTests" \
  || FAILED=1

run_phase "6. WCS foundations" \
  "$TARGET/FoundationsTests" \
  || FAILED=1

echo ""
echo "---- 7. Swift Testing suites (full target sweep) ----"
if ! xcodebuild test-without-building \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  -only-testing:"$TARGET" \
  -resultBundlePath "$XCRESULT" \
  -allowProvisioningUpdates \
  2>&1 | tee -a "$LOG_FILE"; then
  echo "FAILED: Swift Testing sweep" | tee -a "$SUMMARY_FILE"
  FAILED=1
else
  echo "PASSED: Swift Testing sweep" | tee -a "$SUMMARY_FILE"
fi

echo ""
echo "---- 8. UI smoke ----"
if ! xcodebuild test-without-building \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  -only-testing:"Carelens-Aged+UITests/Carelens_Aged_UITests/testLoginScreenAppears" \
  -only-testing:"Carelens-Aged+UITests/Carelens_Aged_UITests/testDarkThemeLoginControlsVisible" \
  -only-testing:"Carelens-Aged+UITests/Carelens_Aged_UITests/testAdminLoginFlow" \
  -only-testing:"Carelens-Aged+UITests/Carelens_Aged_UITests/testDashboardLoads" \
  -only-testing:"Carelens-Aged+UITests/Carelens_Aged_UITests/testTabBarNavigation" \
  -allowProvisioningUpdates \
  2>&1 | tee -a "$LOG_FILE"; then
  echo "FAILED: UI smoke" | tee -a "$SUMMARY_FILE"
  FAILED=1
else
  echo "PASSED: UI smoke" | tee -a "$SUMMARY_FILE"
fi

echo "" | tee -a "$SUMMARY_FILE"
if [ "$FAILED" -eq 0 ]; then
  echo "STATUS: ALL SYSTEMATIC DEVICE E2E PHASES PASSED" | tee -a "$SUMMARY_FILE"
else
  echo "STATUS: ONE OR MORE PHASES FAILED — see $LOG_FILE" | tee -a "$SUMMARY_FILE"
  exit 1
fi

echo "Summary: $SUMMARY_FILE"
