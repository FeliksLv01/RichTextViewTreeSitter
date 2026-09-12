import XCTest
@testable import RichTextViewTreeSitter

final class RichTreeSitterHighlighterTests: XCTestCase {
    func testHighlightsSwiftAndPreservesSource() {
        let highlighter = RichTreeSitterHighlighter()
        let source = "let greeting = \"hello\" // comment"

        let value = highlighter.highlight(code: source, language: "swift")

        XCTAssertEqual(value.attributedString.string, source)
        XCTAssertEqual(value.backend, .treeSitter(canonicalLanguage: "swift"))
        XCTAssertNotEqual(color(in: value.attributedString, token: "let"), color(in: value.attributedString, token: "greeting"))
        XCTAssertNotEqual(color(in: value.attributedString, token: "\"hello\""), color(in: value.attributedString, token: "greeting"))
        XCTAssertNotEqual(color(in: value.attributedString, token: "// comment"), color(in: value.attributedString, token: "greeting"))
    }

    func testIncrementalAppendMatchesFreshHighlighter() {
        let incremental = RichTreeSitterHighlighter()
        let theme = RichTreeSitterTheme.default
        _ = incremental.highlight(code: "let value", language: "swift", theme: theme)
        let updated = incremental.highlight(code: "let value = 42", language: "swift", theme: theme)
        let fresh = RichTreeSitterHighlighter().highlight(code: "let value = 42", language: "swift", theme: theme)

        XCTAssertEqual(updated.attributedString, fresh.attributedString)
    }

    func testUnknownLanguageFallsBackToPlainText() {
        let value = RichTreeSitterHighlighter().highlight(code: "some source", language: "unknown")

        XCTAssertEqual(value.backend, .plainText)
        XCTAssertEqual(value.attributedString.string, "some source")
    }

    func testHighlightJSCompatibilityCatalogContains192Identifiers() {
        XCTAssertEqual(RichTreeSitterLanguageCatalog.highlightJSIdentifiers.count, 192)
        XCTAssertTrue(RichTreeSitterLanguageCatalog.highlightJSIdentifiers.contains("swift"))
        XCTAssertTrue(RichTreeSitterLanguageCatalog.highlightJSIdentifiers.contains("x86asm"))
        XCTAssertEqual(RichTreeSitterLanguageCatalog.canonicalIdentifier(for: "x86asm"), "asm")
    }

    func testCustomThemeOverridesCaptureColor() {
        let keywordColor = UIColor.magenta
        let theme = RichTreeSitterTheme(
            font: .monospacedSystemFont(ofSize: 13, weight: .regular),
            lineHeight: 20,
            textColor: .black,
            backgroundColor: .white,
            tokenStyles: ["keyword": RichTreeSitterTokenStyle(foregroundColor: keywordColor)]
        )

        let value = RichTreeSitterHighlighter().highlight(code: "let value = 1", language: "swift", theme: theme)

        XCTAssertEqual(color(in: value.attributedString, token: "let"), keywordColor)
    }

    func testAllBuiltInThemesHighlightSwift() {
        XCTAssertEqual(RichTreeSitterThemePreset.allCases.count, 4)
        let highlighter = RichTreeSitterHighlighter()

        for preset in RichTreeSitterThemePreset.allCases {
            let theme = RichTreeSitterTheme.preset(preset)
            let value = highlighter.highlight(
                code: "let message = \"hello\"",
                language: "swift",
                theme: theme
            )

            XCTAssertEqual(value.backend, .treeSitter(canonicalLanguage: "swift"), preset.rawValue)
            XCTAssertNotNil(theme.style(for: "keyword"), preset.rawValue)
            XCTAssertNotNil(theme.style(for: "string"), preset.rawValue)
        }
    }

    private func color(in value: NSAttributedString, token: String) -> UIColor? {
        let range = (value.string as NSString).range(of: token)
        return value.attribute(.foregroundColor, at: range.location, effectiveRange: nil) as? UIColor
    }
}
