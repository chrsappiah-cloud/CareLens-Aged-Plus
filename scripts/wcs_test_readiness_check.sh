#!/usr/bin/env bash
# WCS Testing Kit — production readiness check for CareLens Aged+
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

FAIL=0
pass() { echo "  ✓ $1"; }
fail() { echo "  ✗ $1"; FAIL=1; }

echo "WCS Testing Kit — Readiness Check"
echo "================================="

echo ""
echo "1. Standard document"
if [[ -f docs/WCS-Testing-Kit.md ]]; then pass "docs/WCS-Testing-Kit.md"; else fail "Missing docs/WCS-Testing-Kit.md"; fi

echo ""
echo "2. WCS suite files"
WCS_SUITES=(
  AppLaunchTests
  AssertionTests
  LifecycleTests
  CoverageTests
  StartupControllerTests
  StorageTests
  NetworkRequestTests
  NetworkResponseTests
  TextFieldTests
  RefactoringSafetyTests
)
for suite in "${WCS_SUITES[@]}"; do
  if [[ -f "Carelens-Aged+Tests/WCS/${suite}.swift" ]]; then
    pass "$suite"
  else
    fail "Missing WCS suite: $suite"
  fi
done

echo ""
echo "3. Test Zero in every WCS suite"
for suite in "${WCS_SUITES[@]}"; do
  if grep -q "testZero_suiteWiring" "Carelens-Aged+Tests/WCS/${suite}.swift" 2>/dev/null; then
    pass "Test Zero in $suite"
  else
    fail "No Test Zero in $suite"
  fi
done

echo ""
echo "4. Foundations & E2E plan"
if [[ -f Carelens-Aged+Tests/FoundationsTests.swift ]]; then pass "FoundationsTests"; else fail "Missing FoundationsTests"; fi
if grep -q "FoundationsTests" E2ETests.xctestplan; then pass "E2ETests.xctestplan includes FoundationsTests"; else fail "E2ETests.xctestplan missing FoundationsTests"; fi
if grep -q "AppLaunchTests" E2ETests.xctestplan; then pass "E2ETests.xctestplan includes WCS suites"; else fail "E2ETests.xctestplan missing WCS suites"; fi

echo ""
echo "5. CI & device scripts"
if [[ -f .github/workflows/ci.yml ]]; then pass "CI workflow"; else fail "Missing CI workflow"; fi
if [[ -x scripts/run_e2e_device_systematic.sh ]]; then pass "Device E2E script"; else fail "Missing device E2E script"; fi

echo ""
echo "6. UI & snapshot coverage"
if [[ -f Carelens-Aged+UITests/Carelens_Aged_UITests.swift ]]; then pass "UI tests"; else fail "Missing UI tests"; fi
if [[ -f Carelens-Aged+UITests/Carelens_Aged_ScreenshotTests.swift ]]; then pass "Screenshot tests"; else fail "Missing screenshot tests"; fi

echo ""
if [[ "$FAIL" -eq 0 ]]; then
  echo "Result: READY — all WCS checks passed."
  exit 0
else
  echo "Result: GAPS REMAIN — see failures above."
  exit 1
fi
