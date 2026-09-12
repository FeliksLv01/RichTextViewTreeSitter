import Foundation
import SwiftTreeSitter
import UIKit

public enum RichTreeSitterBackend: Equatable, Sendable {
    case treeSitter(canonicalLanguage: String)
    case plainText
}

public struct RichTreeSitterHighlightResult {
    public let attributedString: NSAttributedString
    public let backend: RichTreeSitterBackend

    public init(attributedString: NSAttributedString, backend: RichTreeSitterBackend) {
        self.attributedString = NSAttributedString(attributedString: attributedString)
        self.backend = backend
    }
}

public struct RichTreeSitterLanguage: @unchecked Sendable {
    public let canonicalIdentifier: String
    public let aliases: Set<String>
    public let configuration: LanguageConfiguration

    public init(
        canonicalIdentifier: String,
        aliases: Set<String> = [],
        configuration: LanguageConfiguration
    ) {
        self.canonicalIdentifier = Self.normalize(canonicalIdentifier)
        self.aliases = Set(aliases.map(Self.normalize))
        self.configuration = configuration
    }

    fileprivate static func normalize(_ identifier: String) -> String {
        identifier.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}

public final class RichTreeSitterLanguageRegistry: @unchecked Sendable {
    private let queue = DispatchQueue(label: "io.github.felikslv01.rich-text-view.tree-sitter.registry", attributes: .concurrent)
    private var languages: [String: RichTreeSitterLanguage] = [:]

    public init(languages: [RichTreeSitterLanguage] = []) {
        languages.forEach(register)
    }

    public func register(_ language: RichTreeSitterLanguage) {
        queue.sync(flags: .barrier) {
            languages[language.canonicalIdentifier] = language
            for alias in language.aliases {
                languages[alias] = language
            }
        }
    }

    public func language(for identifier: String) -> RichTreeSitterLanguage? {
        let normalized = RichTreeSitterLanguage.normalize(identifier)
        return queue.sync {
            languages[normalized] ?? languages[RichTreeSitterLanguageCatalog.aliases[normalized] ?? normalized]
        }
    }

    public var registeredIdentifiers: [String] {
        queue.sync { languages.keys.sorted() }
    }
}

public final class RichTreeSitterHighlighter: @unchecked Sendable {
    private final class State {
        let parser: Parser
        let query: Query
        var previousSource = ""
        var previousTree: MutableTree?

        init(language: RichTreeSitterLanguage) throws {
            guard let query = language.configuration.queries[.highlights] else {
                throw RichTreeSitterError.missingHighlightQuery(language.canonicalIdentifier)
            }
            let parser = Parser()
            try parser.setLanguage(language.configuration.language)
            self.parser = parser
            self.query = query
        }
    }

    private let queue = DispatchQueue(label: "io.github.felikslv01.rich-text-view.tree-sitter.highlighter")
    private let registry: RichTreeSitterLanguageRegistry
    private var states: [String: State] = [:]

    public init(registry: RichTreeSitterLanguageRegistry = .standard) {
        self.registry = registry
    }

    public func backend(for languageIdentifier: String) -> RichTreeSitterBackend {
        guard let language = registry.language(for: languageIdentifier) else { return .plainText }
        return .treeSitter(canonicalLanguage: language.canonicalIdentifier)
    }

    public func highlight(
        code: String,
        language languageIdentifier: String,
        theme: RichTreeSitterTheme = .default
    ) -> RichTreeSitterHighlightResult {
        queue.sync {
            let result = baseAttributedString(code: code, theme: theme)
            guard let language = registry.language(for: languageIdentifier),
                  let state = state(for: language),
                  let tree = updatedTree(for: code, state: state),
                  let root = tree.rootNode else {
                return RichTreeSitterHighlightResult(attributedString: result, backend: .plainText)
            }
            let highlights = state.query.execute(node: root, in: tree)
                .resolve(with: Predicate.Context(string: code))
                .highlights()
            for highlight in highlights {
                guard highlight.range.location >= 0,
                      NSMaxRange(highlight.range) <= result.length,
                      let style = theme.style(for: highlight.name) else { continue }
                apply(style: style, to: result, range: highlight.range)
            }
            return RichTreeSitterHighlightResult(
                attributedString: result,
                backend: .treeSitter(canonicalLanguage: language.canonicalIdentifier)
            )
        }
    }

    public func reset(language languageIdentifier: String? = nil) {
        queue.sync {
            guard let languageIdentifier,
                  let language = registry.language(for: languageIdentifier) else {
                states.removeAll()
                return
            }
            states.removeValue(forKey: language.canonicalIdentifier)
        }
    }

    private func state(for language: RichTreeSitterLanguage) -> State? {
        if let state = states[language.canonicalIdentifier] {
            return state
        }
        guard let state = try? State(language: language) else { return nil }
        states[language.canonicalIdentifier] = state
        return state
    }

    private func updatedTree(for source: String, state: State) -> MutableTree? {
        defer { state.previousSource = source }
        guard source.hasPrefix(state.previousSource), let previousTree = state.previousTree else {
            let tree = state.parser.parse(source)
            state.previousTree = tree
            return tree
        }
        let oldPoint = endPoint(of: state.previousSource)
        previousTree.edit(InputEdit(
            startByte: state.previousSource.utf16.count * 2,
            oldEndByte: state.previousSource.utf16.count * 2,
            newEndByte: source.utf16.count * 2,
            startPoint: oldPoint,
            oldEndPoint: oldPoint,
            newEndPoint: endPoint(of: source)
        ))
        let tree = state.parser.parse(tree: previousTree, string: source)
        state.previousTree = tree
        return tree
    }

    private func baseAttributedString(code: String, theme: RichTreeSitterTheme) -> NSMutableAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = theme.lineHeight
        paragraph.maximumLineHeight = theme.lineHeight
        paragraph.lineBreakMode = .byClipping
        return NSMutableAttributedString(
            string: code,
            attributes: [
                .font: theme.font,
                .foregroundColor: theme.textColor,
                .paragraphStyle: paragraph
            ]
        )
    }

    private func apply(style: RichTreeSitterTokenStyle, to value: NSMutableAttributedString, range: NSRange) {
        if let foregroundColor = style.foregroundColor {
            value.addAttribute(.foregroundColor, value: foregroundColor, range: range)
        }
        if let backgroundColor = style.backgroundColor {
            value.addAttribute(.backgroundColor, value: backgroundColor, range: range)
        }
        if let font = style.font {
            value.addAttribute(.font, value: font, range: range)
        }
    }

    private func endPoint(of source: String) -> Point {
        let lines = source.split(separator: "\n", omittingEmptySubsequences: false)
        return Point(row: max(0, lines.count - 1), column: (lines.last?.utf16.count ?? 0) * 2)
    }
}

public enum RichTreeSitterError: Error, Equatable {
    case missingHighlightQuery(String)
}
