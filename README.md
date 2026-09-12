# RichTextViewTreeSitter

Optional Tree-sitter syntax highlighting for RichTextView on iOS 15 and later.
The renderer stays independent: this package implements RichTextView's global,
single-slot code-block highlighting plugin API.

```swift
RichCodeBlockHighlighting.register(
    TreeSitterCodeBlockHighlightingPlugin(theme: .github)
)
```

The plugin is retained globally and reused across renders. An explicit
`RichContentPresentationResolving` code-block presentation still takes
precedence. Unsupported languages return `nil`, allowing RichTextView to render
its built-in plain-text code block.

```swift
RichCodeBlockHighlighting.unregister()
```

`TreeSitterCodeHighlightTheme` controls the code font, line height, foreground,
background, block insets, corner radius, and per-capture styles. Four presets
are built in: `.github`, `.xcode`, `.monokai`, and `.dracula`; `.default` is an
alias of the adaptive GitHub preset. Capture lookup is hierarchical, so a
`string` style also applies to `string.special` unless a more specific style is
configured.

```swift
let plugin = TreeSitterCodeBlockHighlightingPlugin(theme: .monokai)
RichCodeBlockHighlighting.register(plugin)
plugin.setTheme(.preset(.dracula))
```

The compatibility catalog accepts the 192 language identifiers exposed by the
reference Highlight.js bundle. A language is reported as Tree-sitter-backed
only when its grammar pack is registered; identifiers without a reliable
Tree-sitter grammar degrade to plain text instead of loading JavaScriptCore.

The source workspace currently registers the Swift grammar. Additional grammar
packs and the release XCFramework are generated from the pinned upstream
language manifest. All upstream inputs are Git submodules; HighlighterSwift and
highlight.js are not runtime or build dependencies.

## Installation

Add the package from GitHub. The `main` branch tracks RichTextView's `main`
branch while the packages are under active development:

```swift
.package(
    url: "https://github.com/FeliksLv01/RichTextViewTreeSitter.git",
    branch: "main"
)
```
