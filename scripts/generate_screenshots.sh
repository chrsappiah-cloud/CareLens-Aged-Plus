#!/usr/bin/env bash
# Generates App Store screenshots for iPhone and iPad using UI tests.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

IPHONE_DEVICE="${IPHONE_DEVICE:-iPhone 17 Pro Max}"
IPAD_DEVICE="${IPAD_DEVICE:-iPad Air 11-inch (M3)}"
IOS_VERSION="${IOS_VERSION:-26.5}"

OUT_IPHONE="$ROOT/AppStoreAssets/screenshots/iphone_6.9"
OUT_IPAD="$ROOT/AppStoreAssets/screenshots/ipad_12.9"
mkdir -p "$OUT_IPHONE" "$OUT_IPAD"

run_screenshots() {
  local device="$1"
  local out_dir="$2"
  local result_path="$ROOT/build/ScreenshotResults-${device// /_}.xcresult"

  echo "==> Screenshots on: $device"
  rm -rf "$result_path"

  xcodebuild test \
    -project "Carelens-Aged+.xcodeproj" \
    -scheme "Carelens-Aged+" \
    -destination "platform=iOS Simulator,name=${device},OS=${IOS_VERSION}" \
    -only-testing:"Carelens-Aged+UITests/Carelens_Aged_ScreenshotTests/testCaptureAppStoreScreenshots" \
    -resultBundlePath "$result_path" \
    CODE_SIGNING_ALLOWED=NO \
    | xcbeautify || true

  ruby "$ROOT/scripts/extract_screenshots.rb" "$result_path" "$out_dir"
}

boot_sim() {
  local name="$1"
  local udid
  udid=$(xcrun simctl list devices available | grep "$name (" | head -1 | sed -E 's/.*\(([A-F0-9-]+)\).*/\1/')
  if [[ -n "$udid" ]]; then
    xcrun simctl boot "$udid" 2>/dev/null || true
    xcrun simctl bootstatus "$udid" -b
  fi
}

boot_sim "$IPHONE_DEVICE"
boot_sim "$IPAD_DEVICE"

run_screenshots "$IPHONE_DEVICE" "$OUT_IPHONE"
run_screenshots "$IPAD_DEVICE" "$OUT_IPAD"

echo "Screenshots saved to:"
echo "  $OUT_IPHONE"
echo "  $OUT_IPAD"
