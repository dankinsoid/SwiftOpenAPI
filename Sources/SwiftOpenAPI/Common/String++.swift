import Foundation

extension String {
    
    static func typeName(_ type: Any.Type) -> String {
        String(reflecting: type)
            .components(separatedBy: ["."])
            .dropFirst()
            .joined()
            .filter {
                CharacterSet.alphanumerics.isSuperset(of: CharacterSet($0.unicodeScalars))
            }
    }
}
