// swift-tools-version: 5.9

import PackageDescription

let version = "tree-sitter-0.25.10.1"
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
            checksum: "f2ba9ddb46cf03ea12d769f7299023f73f2e93f84631217e054736bbdc8d9300"
        ),
        .binaryTarget(
            name: "SwiftTreeSitter",
            url: "\(releaseBaseURL)/SwiftTreeSitter.xcframework.zip",
            checksum: "89b8df51b14494290bf71de048d5a1da4a65e6736a264244d19075500383b9c6"
        ),
        .binaryTarget(
            name: "TreeSitterSwift",
            url: "\(releaseBaseURL)/TreeSitterSwift.xcframework.zip",
            checksum: "f85c2df73fd8365a9d28063363d74630fa2495cd39afa591f5641438793c1260"
        )
    ]
)
