#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
DERIVED_DATA="$WORK_DIR/DerivedData"
BUNDLE_ID="io.github.felikslv01.TreeSitterRuntimeConsumer"
trap 'rm -rf "$WORK_DIR"' EXIT

mkdir -p "$WORK_DIR/Tests"
ditto "$ROOT_DIR/Tests/SwiftPMConsumer" "$WORK_DIR/Tests/SwiftPMConsumer"
ditto "$ROOT_DIR/Tests/AppConsumer" "$WORK_DIR/Tests/AppConsumer"
for module in TreeSitter SwiftTreeSitter TreeSitterSwift; do
  ln -s "$ROOT_DIR/Artifacts/$module.xcframework" "$WORK_DIR/Tests/SwiftPMConsumer/$module.xcframework"
done

(
  cd "$WORK_DIR/Tests/AppConsumer"
  xcodegen generate --spec project.yml
)

SIMULATOR_ID="${SIMULATOR_ID:-$(
  xcrun simctl list devices available -j | ruby -rjson -e '
    devices = JSON.parse(STDIN.read).fetch("devices")
    iphone = devices.select { |runtime, _| runtime.include?("iOS") }
                    .values.flatten.find { |device| device.fetch("name").start_with?("iPhone") }
    abort("No available iPhone simulator") unless iphone
    puts iphone.fetch("udid")
  '
)}"
xcrun simctl boot "$SIMULATOR_ID" 2>/dev/null || true
xcrun simctl bootstatus "$SIMULATOR_ID" -b

set -o pipefail
xcodebuild build \
  -project "$WORK_DIR/Tests/AppConsumer/TreeSitterRuntimeConsumer.xcodeproj" \
  -scheme TreeSitterRuntimeConsumer \
  -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO 2>&1 | xcbeautify

APP_PATH="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/TreeSitterRuntimeConsumer.app"
xcrun simctl install "$SIMULATOR_ID" "$APP_PATH"
launch_output="$(xcrun simctl launch --terminate-running-process "$SIMULATOR_ID" "$BUNDLE_ID")"
pid="${launch_output##*: }"
sleep 2
if ! kill -0 "$pid" 2>/dev/null; then
  echo "Tree-sitter runtime consumer terminated during launch" >&2
  exit 1
fi
xcrun simctl terminate "$SIMULATOR_ID" "$BUNDLE_ID"
echo "Verified Tree-sitter parsing during application launch"
