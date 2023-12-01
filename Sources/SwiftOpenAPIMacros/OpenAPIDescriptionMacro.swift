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
    var includeAttributes = false
    node.arguments?.as(LabeledExprListSyntax.self)?.forEach {
        switch $0.label?.text {
        case "codingKeys":
            if $0.bool == false {
                type = .String
            }
        case "docCommentsOnly":
            if $0.bool == true {
                onlyDocComments = true
            }
        case "includeAttributes":
            if $0.bool == true {
                includeAttributes = true
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
            includeAttributes || type == .String || variable.attributes.isEmpty,
            type == .CodingKeys && !variable.modifiers.contains(where: \.name.isStaticOrLazy) 
                || type == .String && !variable.modifiers.contains(where: \.name.isStatic),
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
            if let closure = binding.accessorBlock, type == .CodingKeys {
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
