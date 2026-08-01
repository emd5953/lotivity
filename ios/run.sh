#!/usr/bin/env bash
#
# Build Lotivity, install it on a simulator, and launch it.
#
#   ./run.sh                  # iPhone 17 Pro
#   ./run.sh "iPhone Air"     # any simulator name from `xcrun simctl list devices`
#   ./run.sh --console        # stream the app's stdout until you ^C
#
set -euo pipefail

cd "$(dirname "$0")"

DEVICE="iPhone 17 Pro"
CONSOLE=0
for arg in "$@"; do
    case "$arg" in
        --console) CONSOLE=1 ;;
        -*) echo "unknown option: $arg" >&2; exit 2 ;;
        *) DEVICE="$arg" ;;
    esac
done

BUNDLE_ID="com.lotivity.app"
BUILD_DIR="build"
APP="$BUILD_DIR/Build/Products/Debug-iphonesimulator/Lotivity.app"

# `simctl boot` errors if the device is already up, which is not a failure here.
state=$(xcrun simctl list devices available | grep -F "$DEVICE (" | head -1 \
    | grep -oE '\((Booted|Shutdown|Booting)\)' | tr -d '()')
if [ -z "$state" ]; then
    echo "No simulator named \"$DEVICE\". Available:" >&2
    xcrun simctl list devices available | grep -E "^ +iPhone|^ +iPad" >&2
    exit 1
fi
[ "$state" = "Booted" ] || xcrun simctl boot "$DEVICE"
open -a Simulator

echo "→ building for $DEVICE"
xcodebuild \
    -project Lotivity.xcodeproj \
    -scheme Lotivity \
    -destination "platform=iOS Simulator,name=$DEVICE" \
    -derivedDataPath "$BUILD_DIR" \
    build \
    | grep -E "error:|warning:|BUILD (SUCCEEDED|FAILED)" || true

[ -d "$APP" ] || { echo "build produced no app bundle" >&2; exit 1; }

echo "→ installing"
xcrun simctl install "$DEVICE" "$APP"

# A stale copy left running would keep the old binary on screen.
xcrun simctl terminate "$DEVICE" "$BUNDLE_ID" >/dev/null 2>&1 || true

if [ "$CONSOLE" -eq 1 ]; then
    echo "→ launching (^C to stop)"
    xcrun simctl launch --console-pty "$DEVICE" "$BUNDLE_ID"
else
    echo "→ launching"
    xcrun simctl launch "$DEVICE" "$BUNDLE_ID" >/dev/null
    echo "running on $DEVICE"
fi
