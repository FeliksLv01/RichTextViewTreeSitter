import RichTextView
import UIKit

public final class RichTreeSitterPresentationResolver: RichContentPresentationResolving {
    public var theme: RichTreeSitterTheme
    public let highlighter: RichTreeSitterHighlighter
    public let base: (any RichContentPresentationResolving)?

    public init(
        highlighter: RichTreeSitterHighlighter = RichTreeSitterHighlighter(),
        theme: RichTreeSitterTheme = .default,
        base: (any RichContentPresentationResolving)? = nil
    ) {
        self.highlighter = highlighter
        self.theme = theme
        self.base = base
    }

    public func overrideElement(for node: RichContentNode, context: RichContentRenderContext) -> RichElement? {
        base?.overrideElement(for: node, context: context)
    }

    public func mentionPresentation(for node: RichContentNode, content: RichMentionContent) -> RichMentionPresentation? {
        base?.mentionPresentation(for: node, content: content)
    }

    public func emojiPresentation(for node: RichContentNode, content: RichEmojiContent) -> RichInlineImagePresentation? {
        base?.emojiPresentation(for: node, content: content)
    }

    public func imagePresentation(for node: RichContentNode, content: RichImageContent) -> RichInlineImagePresentation? {
        base?.imagePresentation(for: node, content: content)
    }

    public func codeBlockPresentation(
        for node: RichContentNode,
        content: RichCodeBlockContent,
        code: String,
        context: RichContentRenderContext
    ) -> RichCodeBlockPresentation? {
        let language = content.language.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !language.isEmpty else {
            return base?.codeBlockPresentation(for: node, content: content, code: code, context: context)
        }
        let result = highlighter.highlight(code: code, language: language, theme: theme)
        guard case .treeSitter = result.backend else {
            return base?.codeBlockPresentation(for: node, content: content, code: code, context: context)
        }
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

    public func linkIconPresentation(for node: RichContentNode, content: RichLinkContent) -> RichInlineImagePresentation? {
        base?.linkIconPresentation(for: node, content: content)
    }

    public func resolvedLink(for node: RichContentNode, content: RichLinkContent) -> RichContentResolvedLink? {
        base?.resolvedLink(for: node, content: content)
    }
}
