import SwiftTreeSitter
import TreeSitterSwift

extension RichTreeSitterLanguage {
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
