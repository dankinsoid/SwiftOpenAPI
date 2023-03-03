import Foundation

extension String {
    
    static func typeName(_ type: Any.Type) -> String {
        let string = String(reflecting: type)
        var components = string.components(separatedBy: CharacterSet.alphanumerics.inverted).filter { !$0.isEmpty }
        guard !components.isEmpty else {
            return ""
        }
        if components.count > 1 {
            let prefix = components.removeFirst()
            return components.filter { $0 != prefix }.joined()
        } else {
            return components.joined()
        }
    }
}
