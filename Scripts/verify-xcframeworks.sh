#!/bin/bash

set -euo pipefail

ARTIFACTS_DIR="${1:-$(cd "$(dirname "$0")/.." && pwd)/Artifacts}"

for module in TreeSitter SwiftTreeSitter TreeSitterSwift; do
  framework="$ARTIFACTS_DIR/$module.xcframework"
  if [[ ! -d "$framework" ]]; then
    echo "Missing $framework" >&2
    exit 1
  fi

  device_binary="$(find "$framework" -path '*ios-arm64/*' -type f -name "$module" | head -n 1)"
  simulator_binary="$(find "$framework" -path '*ios-arm64-simulator/*' -type f -name "$module" | head -n 1)"
  if [[ -z "$device_binary" || -z "$simulator_binary" ]]; then
    echo "$module is missing an iOS device or arm64 simulator slice" >&2
    exit 1
  fi
  if ! file "$device_binary" | grep -q 'current ar archive'; then
    echo "$module device slice is not a static library" >&2
    exit 1
  fi
  if ! file "$simulator_binary" | grep -q 'current ar archive'; then
    echo "$module simulator slice is not a static library" >&2
    exit 1
  fi
  lipo -info "$device_binary"
  lipo -info "$simulator_binary"
done

echo "Verified static Tree-sitter XCFramework slices"
