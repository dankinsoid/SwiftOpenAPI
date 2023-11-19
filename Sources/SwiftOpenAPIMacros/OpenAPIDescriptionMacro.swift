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

public struct OpenAPIDescriptionMacro: ExtensionMacro, MemberMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        try _expansion(of: node, providingMembersOf: declaration, in: context)
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        [openAPIDescriptableExtension(for: type)]
    }
}

private func _expansion(
    of node: AttributeSyntax,
    providingMembersOf declaration: some DeclGroupSyntax,
    in context: some MacroExpansionContext
) throws -> [DeclSyntax] {
    var onlyDocComments = false
    var type: DescriptionType = .CodingKeys
    node.arguments?.as(LabeledExprListSyntax.self)?.forEach {
        switch $0.label?.text {
        case "codingKeys":
            if $0.expression.as(BooleanLiteralExprSyntax.self)?.literal.text == "false" {
                type = .String
            }
        case "docCommentsOnly":
            if $0.expression.as(BooleanLiteralExprSyntax.self)?.literal.text == "true" {
                onlyDocComments = true
            }
        default:
            break
        }
    }
    let typeDoc = declaration
        .children(viewMode: .all)
        .compactMap { $0.documentation(onlyDocComment: onlyDocComments) }
        .first?
        .wrapped
    let varDocs = declaration.memberBlock.members.compactMap { member -> (String, String)? in
        guard
            let variable = member.decl.as(VariableDeclSyntax.self),
            variable.attributes.isEmpty,
            !variable.modifiers.contains(where: \.name.isStaticOrLazy),
            let doc = variable.documentation(onlyDocComment: false)
        else {
            return nil
        }
        var name: String?
        for binding in variable.bindings {
            guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
                continue
            }
            name = identifier.identifier.text
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
        "\n        .add(for: \(type.wrap(name: $0.0)), \($0.1.wrapped))"
    }
    .joined()
    
    let openAPIDescription: DeclSyntax =
      """
      
      public static var openAPIDescription: OpenAPIDescriptionType? {
          OpenAPIDescription<\(raw: type.rawValue)>(\(raw: typeDoc ?? ""))\(raw: varDocsModifiers)
      }
      """
    return [openAPIDescription]
}

private enum DescriptionType: String {
    
    case CodingKeys
    case String
    
    func wrap(name: String) -> String {
        switch self {
        case .CodingKeys:
            return ".\(name)"
        case .String:
            return "\"\(name)\""
        }
    }
}

private func openAPIDescriptableExtension(for type: some TypeSyntaxProtocol) -> ExtensionDeclSyntax {
    ExtensionDeclSyntax(
        extendedType: type,
        inheritanceClause: InheritanceClauseSyntax(
            inheritedTypes: InheritedTypeListSyntax {
                InheritedTypeSyntax(
                    type: TypeSyntax(stringLiteral: "OpenAPIDescriptable")
                )
            }
        ),
        memberBlock: MemberBlockSyntax(members: MemberBlockItemListSyntax())
    )
}
#endif
