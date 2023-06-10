import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder

public struct DefaultValuesMacro: MemberMacro {
  
  public static func expansion<Declaration: DeclGroupSyntax, Context: MacroExpansionContext>(
    of node: AttributeSyntax,
    providingMembersOf declaration: Declaration,
    in context: Context
  ) throws -> [DeclSyntax] {
    let memberList = declaration.storedProperties()
    
    let values = memberList.compactMap { member -> (String, String)? in
      guard let defaultValue = member.bindings.first?.initializer?.value else {
        return nil
      }
      guard let name = member.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text else {
        return nil
      }
      return (name, "\(defaultValue)")
    }
    
    let strings: DeclSyntax = """
    
    static var defaultValues: DefaultValues {
        DefaultValues()
            \(raw: values.map { ".add(CodingKeys.\($0.0), \($0.1))" }.joined(separator: "\n        "))
    }
    """
    
    return [
      strings
    ]
  }
}
