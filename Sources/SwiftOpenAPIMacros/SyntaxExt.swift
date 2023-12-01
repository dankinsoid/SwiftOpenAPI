#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

extension TokenSyntax {
    
    var isWillSetOrDidSet: Bool {
        tokenKind == .keyword(.didSet) || tokenKind == .keyword(.willSet)
    }
    
    var isStaticOrLazy: Bool {
        isStatic || tokenKind == .keyword(.lazy)
    }
    
    var isStatic: Bool {
        tokenKind == .keyword(.static)
    }
}

extension SyntaxProtocol {
    
    func documentation(onlyDocComment: Bool) -> String? {
        leadingTrivia.documentation(onlyDocComment: onlyDocComment)
    }
}

extension Trivia {
    
    func documentation(onlyDocComment: Bool) -> String? {
        let lines = compactMap { $0.documentation(onlyDocComment: onlyDocComment) }
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
    
    func documentation(onlyDocComment: Bool) -> String? {
        switch self {
        case let .docLineComment(comment):
            let startIndex = comment.index(comment.startIndex, offsetBy: 3)
            return String(comment.suffix(from: startIndex))
        case let .lineComment(comment):
            guard !onlyDocComment else { return nil }
            let startIndex = comment.index(comment.startIndex, offsetBy: 2)
            return String(comment.suffix(from: startIndex))
        case let .docBlockComment(comment):
            let startIndex = comment.index(comment.startIndex, offsetBy: 3)
            let endIndex = comment.index(comment.endIndex, offsetBy: -2)
            return String(comment[startIndex ..< endIndex])
        case let .blockComment(comment):
            guard !onlyDocComment else { return nil }
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

extension LabeledExprListSyntax {
    
    func bool(_ name: String) -> Bool? {
        first { $0.label?.text == name }?.bool
    }
}

extension LabeledExprListSyntax.Element {
    
    var bool: Bool? {
        (expression.as(BooleanLiteralExprSyntax.self)?.literal.text).map {
            $0 == "true"
        }
    }
}

extension AttributeSyntax.Arguments {
    
    func bool(_ name: String) -> Bool? {
        self.as(LabeledExprListSyntax.self)?.bool(name)
    }
}
#endif
