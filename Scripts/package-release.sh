#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ARTIFACTS_DIR="${ARTIFACTS_DIR:-$ROOT_DIR/Artifacts}"
RELEASE_DIR="${RELEASE_DIR:-$ROOT_DIR/.build/release}"

"$ROOT_DIR/Scripts/verify-xcframeworks.sh" "$ARTIFACTS_DIR"
rm -rf "$RELEASE_DIR"
mkdir -p "$RELEASE_DIR"

for module in TreeSitter SwiftTreeSitter TreeSitterSwift; do
  ditto -c -k --sequesterRsrc --keepParent \
    "$ARTIFACTS_DIR/$module.xcframework" \
    "$RELEASE_DIR/$module.xcframework.zip"
  swift package compute-checksum "$RELEASE_DIR/$module.xcframework.zip"
done

ditto -c -k --sequesterRsrc \
  --keepParent "$ARTIFACTS_DIR" \
  "$RELEASE_DIR/RichTextViewTreeSitter.xcframeworks.zip"
shasum -a 256 "$RELEASE_DIR/RichTextViewTreeSitter.xcframeworks.zip"
