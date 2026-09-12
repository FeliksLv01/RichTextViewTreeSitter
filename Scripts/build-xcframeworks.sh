#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-$ROOT_DIR/.build/xcframework}"
OUTPUT_DIR="${OUTPUT_DIR:-$ROOT_DIR/Artifacts}"
SOURCE_DIR="$BUILD_DIR/source"

for dependency in swift-tree-sitter tree-sitter tree-sitter-swift; do
  if [[ ! -f "$ROOT_DIR/Vendor/$dependency/Package.swift" ]]; then
    echo "Missing submodule Vendor/$dependency. Run: git submodule update --init" >&2
    exit 1
  fi
done

rm -rf "$BUILD_DIR" "$OUTPUT_DIR"
mkdir -p "$SOURCE_DIR" "$OUTPUT_DIR"

for dependency in swift-tree-sitter tree-sitter tree-sitter-swift; do
  git clone --quiet --no-hardlinks "$ROOT_DIR/Vendor/$dependency" "$SOURCE_DIR/$dependency"
done

git -C "$SOURCE_DIR/tree-sitter" apply "$ROOT_DIR/Patches/tree-sitter-static-framework.patch"
git -C "$SOURCE_DIR/tree-sitter-swift" apply "$ROOT_DIR/Patches/tree-sitter-swift-static-framework.patch"
ruby -pi -e 'sub(%q{.library(name: "SwiftTreeSitter", targets: ["SwiftTreeSitter"])}, %q{.library(name: "SwiftTreeSitter", type: .static, targets: ["SwiftTreeSitter"])})' \
  "$SOURCE_DIR/swift-tree-sitter/Package.swift"
ruby -pi -e 'sub(%q{.package(url: "https://github.com/tree-sitter/tree-sitter", .upToNextMinor(from: "0.25.0"))}, %q{.package(path: "../tree-sitter")})' \
  "$SOURCE_DIR/swift-tree-sitter/Package.swift"
grep -Fq '.library(name: "SwiftTreeSitter", type: .static' "$SOURCE_DIR/swift-tree-sitter/Package.swift"
grep -Fq '.package(path: "../tree-sitter")' "$SOURCE_DIR/swift-tree-sitter/Package.swift"

archive() {
  local source="$1"
  local scheme="$2"
  local sdk="$3"
  local destination="$4"
  local archive_path="$5"
  local derived_data="$6"
  shift 6

  (
    cd "$source"
    set -o pipefail
    xcodebuild archive \
      -scheme "$scheme" \
      -destination "$destination" \
      -archivePath "$archive_path" \
      -derivedDataPath "$derived_data" \
      -configuration Release \
      SKIP_INSTALL=NO \
      BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
      MACH_O_TYPE=staticlib \
      CODE_SIGNING_ALLOWED=NO \
      "$@" 2>&1 | xcbeautify
  )

  local framework="$archive_path/Products/usr/local/lib/$scheme.framework"
  if [[ ! -f "$framework/$scheme" ]]; then
    local object_file
    object_file="$(find "$archive_path/Products/Users" -type f -name "$scheme.o" | head -n 1)"
    if [[ -z "$object_file" ]]; then
      echo "Missing static object for $scheme in $archive_path" >&2
      exit 1
    fi
    mkdir -p "$framework"
    ditto "$object_file" "$framework/$scheme"
  fi
  cp "$ROOT_DIR/Support/StaticFrameworkInfo.plist" "$framework/Info.plist"
  plutil -insert CFBundleExecutable -string "$scheme" "$framework/Info.plist"
  plutil -insert CFBundleIdentifier -string "io.github.felikslv01.$scheme" "$framework/Info.plist"

  if [[ "$scheme" == "SwiftTreeSitter" ]]; then
    local module_dir
    module_dir="$(find "$derived_data" -type d -path "*Release-$sdk/$scheme.swiftmodule" | head -n 1)"
    if [[ -z "$module_dir" || ! -d "$framework" ]]; then
      echo "Missing $scheme framework or Swift module for $sdk" >&2
      exit 1
    fi
    mkdir -p "$framework/Modules"
    ditto "$module_dir" "$framework/Modules/$scheme.swiftmodule"
  else
    mkdir -p "$framework/Headers" "$framework/Modules"
    if [[ "$scheme" == "TreeSitter" ]]; then
      ditto "$source/lib/include" "$framework/Headers"
    else
      ditto "$source/bindings/swift/TreeSitterSwift" "$framework/Headers"
    fi
    cp "$ROOT_DIR/Support/$scheme.modulemap" "$framework/Modules/module.modulemap"
  fi
}

build_product() {
  local source_name="$1"
  local product_name="$2"
  local source="$SOURCE_DIR/$source_name"
  local device_archive="$BUILD_DIR/$product_name-iOS.xcarchive"
  local simulator_archive="$BUILD_DIR/$product_name-iOS-Simulator.xcarchive"
  local device_derived="$BUILD_DIR/DerivedData-$product_name-iOS"
  local simulator_derived="$BUILD_DIR/DerivedData-$product_name-iOS-Simulator"

  archive "$source" "$product_name" iphoneos "generic/platform=iOS" "$device_archive" "$device_derived"
  archive "$source" "$product_name" iphonesimulator "generic/platform=iOS Simulator" "$simulator_archive" "$simulator_derived" ARCHS=arm64 ONLY_ACTIVE_ARCH=NO

  xcodebuild -create-xcframework \
    -framework "$device_archive/Products/usr/local/lib/$product_name.framework" \
    -framework "$simulator_archive/Products/usr/local/lib/$product_name.framework" \
    -output "$OUTPUT_DIR/$product_name.xcframework"
}

build_product tree-sitter TreeSitter
build_product swift-tree-sitter SwiftTreeSitter
build_product tree-sitter-swift TreeSitterSwift

"$ROOT_DIR/Scripts/verify-xcframeworks.sh" "$OUTPUT_DIR"
echo "Created XCFrameworks in $OUTPUT_DIR"
