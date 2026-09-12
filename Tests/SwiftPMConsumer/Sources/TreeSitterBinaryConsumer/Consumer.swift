import SwiftTreeSitter
import TreeSitterSwift

public func parseSwift(_ source: String) -> Bool {
    let parser = Parser()
    do {
        try parser.setLanguage(Language(language: tree_sitter_swift()))
        return parser.parse(source)?.rootNode != nil
    } catch {
        return false
    }
}
