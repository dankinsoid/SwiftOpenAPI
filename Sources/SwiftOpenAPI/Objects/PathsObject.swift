import Foundation

public struct PathsObject: Codable, Equatable, SpecificationExtendable, ExpressibleByDictionary {
    
    public typealias Key = Path
    public typealias Value = ReferenceOr<PathItemObject>
    
    public var value: [Key: Value]
    
    public init(_ value: [Key: Value] = [:]) {
        self.value = value
    }
    
    public init(dictionaryElements elements: [(Key, Value)]) {
        self.init(
            Dictionary(elements) { _, second in
                second
            }
        )
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Key.self)
        let pairs = try container.allKeys.map {
            try ($0, container.decode(Value.self, forKey: $0))
        }
        self = Self.init(
            Dictionary(pairs) { _, second in
                second
            }
        )
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Key.self)
        for (key, object) in value {
            try container.encode(object, forKey: key)
        }
    }
}
