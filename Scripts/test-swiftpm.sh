#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

"$ROOT_DIR/Scripts/verify-xcframeworks.sh" "$ROOT_DIR/Artifacts"
ditto "$ROOT_DIR/Tests/SwiftPMConsumer" "$WORK_DIR/Consumer"
for module in TreeSitter SwiftTreeSitter TreeSitterSwift; do
  ln -s "$ROOT_DIR/Artifacts/$module.xcframework" "$WORK_DIR/Consumer/$module.xcframework"
done

for destination in 'generic/platform=iOS' 'generic/platform=iOS Simulator'; do
  (
    cd "$WORK_DIR/Consumer"
    set -o pipefail
    xcodebuild build \
      -scheme TreeSitterBinaryConsumer \
      -destination "$destination" \
      ARCHS=arm64 ONLY_ACTIVE_ARCH=NO \
      CODE_SIGNING_ALLOWED=NO 2>&1 | xcbeautify
  )
done
