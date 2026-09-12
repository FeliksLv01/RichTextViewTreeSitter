# RichTextViewTreeSitter

Optional Tree-sitter syntax highlighting for RichTextView on iOS 15 and later.
The renderer stays independent: this package supplies an injectable code-block
presentation resolver.

```swift
let resolver = RichTreeSitterPresentationResolver()
let context = RichContentRenderContext(
    constrainedWidth: width,
    configuration: .standard,
    resolver: resolver
)
```

For direct use:

```swift
let highlighter = RichTreeSitterHighlighter()
let result = highlighter.highlight(code: source, language: "swift")
```

`RichTreeSitterTheme` controls the code font, line height, foreground,
background, block insets, corner radius, and per-capture styles. Capture lookup
is hierarchical, so a `string` style also applies to `string.special` unless a
more specific style is configured.

The compatibility catalog accepts the 192 language identifiers exposed by the
reference Highlight.js bundle. A language is reported as Tree-sitter-backed
only when its grammar pack is registered; identifiers without a reliable
Tree-sitter grammar degrade to plain text instead of loading JavaScriptCore.

The source workspace currently registers the Swift grammar. Additional grammar
packs and the release XCFramework are generated from the pinned upstream
language manifest. All upstream inputs are Git submodules; HighlighterSwift and
highlight.js are not runtime or build dependencies.
