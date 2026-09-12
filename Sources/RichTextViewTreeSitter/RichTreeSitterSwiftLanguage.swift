import SwiftTreeSitter
import TreeSitterSwift

public extension RichTreeSitterLanguage {
    static var swift: Self {
        get throws {
            let configuration = try LanguageConfiguration(
                Language(language: tree_sitter_swift()),
                name: "Swift"
            )
            return Self(
                canonicalIdentifier: "swift",
                aliases: ["swiftlang"],
                configuration: configuration
            )
        }
    }
}

public extension RichTreeSitterLanguageRegistry {
    static var standard: RichTreeSitterLanguageRegistry {
        let languages = [try? RichTreeSitterLanguage.swift].compactMap { $0 }
        return RichTreeSitterLanguageRegistry(languages: languages)
    }
}
