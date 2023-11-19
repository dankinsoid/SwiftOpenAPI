#if canImport(SwiftCompilerPlugin)
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

@main
struct OpenAPIDescriptionPlugin: CompilerPlugin {

    let providingMacros: [Macro.Type] = [
        OpenAPIDescriptionMacro.self
    ]
}

public struct OpenAPIDescriptionMacro: ExtensionMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let typeDoc = declaration
            .children(viewMode: .all)
            .compactMap(\.documentation)
            .first?
            .wrapped
        let varDocs = declaration.memberBlock.members.compactMap { member -> (String, String)? in
            guard 
                let variable = member.decl.as(VariableDeclSyntax.self),
                variable.attributes.isEmpty,
                let doc = variable.documentation
            else {
                return nil
            }

            var name: String?
            for binding in variable.bindings {
                if let identifier = binding.pattern.as(IdentifierPatternSyntax.self) {
                    name = identifier.identifier.text
                }
                if let closure = binding.accessorBlock {
                    guard 
                        let list = closure.accessors.as(AccessorDeclListSyntax.self),
                        list.contains(where: \.accessorSpecifier.isWillSetOrDidSet)
                    else {
                        return nil
                    }
                }
            }
            return name.map { ($0, doc) }
        }
        let varDocsModifiers = varDocs.map {
            "\n            .add(for: \"\($0.0)\", \($0.1.wrapped))"
        }
        .joined()
    
        let sendableExtension: DeclSyntax =
      """
      extension \(type.trimmed): OpenAPIDescriptable {

          public static var openAPIDescription: OpenAPIDescriptionType? {
              OpenAPIDescription<String>(\(raw: typeDoc ?? ""))\(raw: varDocsModifiers)
          }
      }
      """

        guard let extensionDecl = sendableExtension.as(ExtensionDeclSyntax.self) else {
            throw StringError("Failed to create extension declaration")
        }
        
        return [extensionDecl]
    }
}
#endif
