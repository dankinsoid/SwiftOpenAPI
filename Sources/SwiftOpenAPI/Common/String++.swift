import Foundation

extension String {
    
    static func typeName(_ type: Any.Type) -> String {
        String(describing: type)
            .filter {
                CharacterSet.alphanumerics.isSuperset(of: CharacterSet($0.unicodeScalars))
            }
    }
}
