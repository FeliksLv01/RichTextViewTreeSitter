// swift-tools-version: 5.9

import PackageDescription

let version = "tree-sitter-0.25.10.2"
let releaseBaseURL = "https://github.com/FeliksLv01/RichTextViewTreeSitter/releases/download/\(version)"

let package = Package(
    name: "RichTextViewTreeSitterBinary",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "RichTextViewTreeSitterBinary",
            targets: ["TreeSitter", "SwiftTreeSitter", "TreeSitterSwift"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "TreeSitter",
            url: "\(releaseBaseURL)/TreeSitter.xcframework.zip",
            checksum: "5fac4aff46f9f37a9a6b84f013a0f10f1262a10707a61c08d3a847197cb44fbf"
        ),
        .binaryTarget(
            name: "SwiftTreeSitter",
            url: "\(releaseBaseURL)/SwiftTreeSitter.xcframework.zip",
            checksum: "9654d1151b6f6da90186bfd1ceab146f0b1e779294226602da1741d2a7750653"
        ),
        .binaryTarget(
            name: "TreeSitterSwift",
            url: "\(releaseBaseURL)/TreeSitterSwift.xcframework.zip",
            checksum: "5f49f40984a4258c10ffd24eb401cee5bd18ee048ce63a3b2e1a94d8b20fffe8"
        )
    ]
)
