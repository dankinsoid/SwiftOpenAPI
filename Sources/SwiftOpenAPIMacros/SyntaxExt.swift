#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

extension TokenSyntax {
    
    var isWillSetOrDidSet: Bool {
        self == .keyword(.didSet) || self == .keyword(.willSet)
    }
}

extension SyntaxProtocol {
    
    var documentation: String? {
        leadingTrivia.documentation
    }
}

extension Trivia {
    
    var documentation: String? {
        let lines = compactMap { $0.documentation }
        guard lines.count > 1 else { return lines.first?.trimmingCharacters(in: .whitespaces) }
        
        let indentation = lines.compactMap { $0.firstIndex(where: { !$0.isWhitespace })?.utf16Offset(in: $0) }
            .min() ?? 0
        
        return lines.map {
            guard $0.count > indentation else { return String($0) }
            return String($0.suffix($0.count - indentation))
        }.joined(separator: "\\n")
    }
}

extension TriviaPiece {
    
    var documentation: String? {
        switch self {
        case let .docLineComment(comment):
            let startIndex = comment.index(comment.startIndex, offsetBy: 3)
            return String(comment.suffix(from: startIndex))
        case let .lineComment(comment):
            let startIndex = comment.index(comment.startIndex, offsetBy: 2)
            return String(comment.suffix(from: startIndex))
        case let .docBlockComment(comment):
            let startIndex = comment.index(comment.startIndex, offsetBy: 3)
            let endIndex = comment.index(comment.endIndex, offsetBy: -2)
            return String(comment[startIndex ..< endIndex])
        case let .blockComment(comment):
            let startIndex = comment.index(comment.startIndex, offsetBy: 2)
            let endIndex = comment.index(comment.endIndex, offsetBy: -2)
            return String(comment[startIndex ..< endIndex])
        default:
            return nil
        }
    }
}

extension String {
    
    var wrapped: String {
        "#\"\(self)\"#"
    }
}
#endif
