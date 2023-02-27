import Foundation

public struct Path: Hashable, ExpressibleByStringInterpolation, CodingKey, ExpressibleByArray {
    
    public typealias ArrayLiteralElement = PathElement
    
    public var path: [PathElement]
    public var intValue: Int? { nil }
    public var stringValue: String {
        "/" + path.map(\.string).joined(separator: "/")
    }
    
    public init(stringValue: String) {
        self.path = stringValue
            .components(separatedBy: ["/"])
            .lazy
            .filter { !$0.isEmpty }
            .map {
                PathElement($0)
            }
    }
    
    public init?(intValue: Int) {
        return nil
    }
    
    public init(_ path: [PathElement]) {
        self.path = path
    }
    
    public init(stringLiteral value: String) {
        self.init(stringValue: value)
    }
    
    public init(arrayElements elements: [PathElement]) {
        self.init(elements)
    }
    
    public init(stringInterpolation value: DefaultStringInterpolation) {
        self.init(stringValue: String(stringInterpolation: value))
    }
}

public enum PathElement: Hashable, ExpressibleByStringLiteral {
    
    case constant(String)
    case variable(String)
    
    public var string: String {
        switch self {
        case .constant(let string):
            return string
        case .variable(let string):
            return "{\(string)}"
        }
    }
    
    public init(stringLiteral value: String) {
        self.init(value)
    }
    
    public init(_ string: String) {
        if string.hasPrefix("{") || string.hasSuffix("}") {
            self = .variable(string.trimmingCharacters(in: ["{", "}"]))
        } else {
            self = .constant(string)
        }
    }
}

public extension PathElement {
    
    static let components: PathElement = "components"
}
