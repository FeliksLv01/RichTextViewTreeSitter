#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
"$ROOT_DIR/Scripts/verify-xcframeworks.sh" "$ROOT_DIR/Artifacts"

ruby -e 'require "cocoapods"; Pod::Command.plugin_prefixes = []; Pod::Command.run(ARGV)' -- \
  lib lint "$ROOT_DIR/RichTextViewTreeSitterBinary.podspec" \
  --allow-warnings \
  --platforms=ios \
  --skip-import-validation \
  --verbose
