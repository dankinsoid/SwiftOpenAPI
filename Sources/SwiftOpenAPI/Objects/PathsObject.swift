import Foundation

public struct PathsObject: Codable, Equatable, SpecificationExtendable, ExpressibleByDictionaryLiteral {
    
    public typealias Key = String
    public typealias Value = ReferenceOr<PathItemObject>
    
    public var value: [Key: Value]
    
    public init(_ value: [Key: Value] = [:]) {
        self.value = value
    }
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(
            Dictionary(elements) { _, second in
                second
            }
        )
    }
    
    public init(from decoder: Decoder) throws {
        try self.init(Dictionary(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}
