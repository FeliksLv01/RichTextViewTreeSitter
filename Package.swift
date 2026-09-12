// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "RichTextViewTreeSitter",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "RichTextViewTreeSitter", targets: ["RichTextViewTreeSitter"])
    ],
    dependencies: [
        .package(url: "https://github.com/FeliksLv01/RichTextView.git", branch: "main"),
        .package(url: "https://github.com/tree-sitter/swift-tree-sitter.git", exact: "0.25.0"),
        .package(url: "https://github.com/alex-pinkus/tree-sitter-swift.git", exact: "0.7.3-with-generated-files")
    ],
    targets: [
        .target(
            name: "RichTextViewTreeSitter",
            dependencies: [
                .product(name: "RichTextView", package: "RichTextView"),
                .product(name: "SwiftTreeSitter", package: "swift-tree-sitter"),
                .product(name: "TreeSitterSwift", package: "tree-sitter-swift")
            ]
        ),
        .testTarget(
            name: "RichTextViewTreeSitterTests",
            dependencies: ["RichTextViewTreeSitter"]
        )
    ]
)
