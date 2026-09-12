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
        .package(path: "Vendor/tree-sitter"),
        .package(path: "Vendor/swift-tree-sitter"),
        .package(path: "Vendor/tree-sitter-swift")
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
