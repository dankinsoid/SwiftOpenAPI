import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

extension VariableDeclSyntax {
    
    /// Determine whether this variable has the syntax of a stored property.
    ///
    /// This syntactic check cannot account for semantic adjustments due to,
    /// e.g., accessor macros or property wrappers.
    var isStoredProperty: Bool {
        if bindings.count != 1 {
            return false
        }
        
        let binding = bindings.first!
        switch binding.accessor {
        case .none:
            return true
            
        case .accessors(let node):
            for accessor in node.accessors {
                switch accessor.accessorKind.tokenKind {
                case .keyword(.willSet), .keyword(.didSet):
                    // Observers can occur on a stored property.
                    break
                    
                default:
                    // Other accessors make it a computed property.
                    return false
                }
            }
            
            return true
            
        case .getter:
            return false
        }
    }
}

extension DeclGroupSyntax {
    /// Enumerate the stored properties that syntactically occur in this
    /// declaration.
    func storedProperties() -> [VariableDeclSyntax] {
        return memberBlock.members.compactMap { member in
            guard let variable = member.decl.as(VariableDeclSyntax.self),
                  variable.isStoredProperty else {
                return nil
            }
            
            return variable
        }
    }
}
