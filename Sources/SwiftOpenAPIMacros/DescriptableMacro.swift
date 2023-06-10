import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct DescriptableMacro: MemberMacro {
  
  public static func expansion<Declaration: DeclGroupSyntax, Context: MacroExpansionContext>(
    of node: AttributeSyntax,
    providingMembersOf declaration: Declaration,
    in context: Context
  ) throws -> [DeclSyntax] {
    let memberList = declaration.storedProperties()
    
    let comments = memberList.compactMap { member -> (String, String)? in
      guard let comment = member.leadingTrivia.docComment else {
        return nil
      }
      guard let name = member.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
        return nil
      }
      return (name, comment)
    }
    let typeComment = declaration.leadingTrivia.docComment
    
    let strings: DeclSyntax = """
    
    static var openAPIDescription: OpenAPIDescriptionType {
        OpenAPIDescription<CodingKeys>(\(raw: typeComment?.fullQuoted ?? "nil"))
            \(raw: comments.map { ".add(.\($0.0), \($0.1.fullQuoted))" }.joined(separator: "\n        "))
    }
    """
    
    return [
      strings
    ]
  }
}

private extension Trivia {
  
  var docComment: String? {
    let array = pieces.lazy.compactMap { piece -> String? in
      switch piece {
      case let .docLineComment(comment), let .docBlockComment(comment):
        return comment
      default:
        return nil
      }
    }.map {
      $0.clearComment
    }
    .filter { !$0.isEmpty }
    
    let trimCount = array.map { $0.prefix(while: \.isWhitespace).count }.min() ?? 0
    
    let result: String = array.map {
        $0.dropFirst(trimCount)
      }
      .joined(separator: "\n")
      .trimmingCharacters(in: ["\n"])
    return result.isEmpty ? nil : result
  }
}

private extension String {
  
  var clearComment: String {
    var result = self
    if result.hasPrefix("/**") {
      result.removeFirst(3)
      if result.hasSuffix("*/") {
        result.removeLast(2)
      }
    } else if result.hasPrefix("///") {
      result.removeFirst(3)
    }
    return result.trimmingCharacters(in: ["\n"])
  }
}
