import RichTextView
import UIKit

public final class TreeSitterCodeBlockHighlightingPlugin: RichCodeBlockHighlightingPlugin, @unchecked Sendable {
    private let themeLock = NSLock()
    private let highlighter: RichTreeSitterHighlighter
    private var storedTheme: TreeSitterCodeHighlightTheme

    public init(
        theme: TreeSitterCodeHighlightTheme = .default,
        maximumCachedCodeBlocks: Int = 64
    ) {
        storedTheme = theme
        highlighter = RichTreeSitterHighlighter(maximumCachedCodeBlocks: maximumCachedCodeBlocks)
    }

    public func setTheme(_ theme: TreeSitterCodeHighlightTheme) {
        themeLock.lock()
        storedTheme = theme
        themeLock.unlock()
    }

    public func codeBlockPresentation(
        for code: String,
        language: String,
        nodeID: String
    ) -> RichCodeBlockPresentation? {
        let language = language.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !language.isEmpty,
              case .treeSitter = highlighter.backend(for: language) else {
            return nil
        }
        let theme = currentTheme
        let result = highlighter.highlight(
            code: code,
            language: language,
            nodeID: nodeID,
            theme: theme
        )
        guard case .treeSitter = result.backend else { return nil }
        return RichCodeBlockPresentation(
            attributedCode: result.attributedString,
            backgroundColor: theme.backgroundColor,
            contentInsets: RichContainerInsets(
                top: theme.codeBlockInsets.top,
                left: theme.codeBlockInsets.left,
                bottom: theme.codeBlockInsets.bottom,
                right: theme.codeBlockInsets.right
            ),
            cornerRadius: theme.codeBlockCornerRadius
        )
    }

    private var currentTheme: TreeSitterCodeHighlightTheme {
        themeLock.lock()
        defer { themeLock.unlock() }
        return storedTheme
    }
}
