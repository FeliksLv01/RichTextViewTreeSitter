#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="$(tr -d '[:space:]' < "$ROOT_DIR/VERSION")"
EXPECTED_TAG="tree-sitter-$VERSION"

if [[ "${GITHUB_REF:-}" != "refs/heads/main" ]]; then
  echo "Releases are only allowed from main" >&2
  exit 1
fi

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid version: $VERSION" >&2
  exit 1
fi

if git -C "$ROOT_DIR" rev-parse "$EXPECTED_TAG" >/dev/null 2>&1; then
  echo "Tag already exists: $EXPECTED_TAG" >&2
  exit 1
fi

echo "$EXPECTED_TAG"
