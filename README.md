# RichTextViewTreeSitterBinary

Pinned static XCFramework distributions used by
[RichTextView](https://github.com/FeliksLv01/RichTextView) for built-in code
block syntax highlighting.

This repository contains no RichTextView public API or highlighting theme API.
It only packages these upstream implementations:

- Tree-sitter 0.25.10
- SwiftTreeSitter 0.25.0
- tree-sitter-swift 0.7.3-with-generated-files

All three upstream projects are pinned as Git submodules. Consumers download
release artifacts rather than cloning or compiling their source trees.

## Artifacts

Each release contains three static XCFrameworks with iOS device arm64 and iOS
Simulator arm64 slices:

- `TreeSitter.xcframework`
- `SwiftTreeSitter.xcframework`
- `TreeSitterSwift.xcframework`

The package manifests temporarily declare a dynamic SwiftPM product so Xcode
creates a framework bundle. The archive command overrides its Mach-O type with
`MACH_O_TYPE=staticlib`; verification fails unless every resulting binary is an
`ar` static archive.

## Build and verify

```sh
git submodule update --init
./Scripts/build-xcframeworks.sh
./Scripts/test-swiftpm.sh
./Scripts/test-cocoapods.sh
```

All Xcode output is formatted with `xcbeautify`. Local and CI tests compile
both iOS device and arm64 simulator consumers.

## Release policy

Only the `Release` GitHub Actions workflow running from `main` may update
checksums, create a `tree-sitter-*` tag, or upload release artifacts. Generated
XCFrameworks and zip files are ignored and never committed, avoiding Git LFS
growth.
