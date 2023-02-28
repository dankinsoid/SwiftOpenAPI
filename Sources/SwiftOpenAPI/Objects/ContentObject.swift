import Foundation

public struct ContentObject<Value: Codable & Equatable>: Codable, Equatable, SpecificationExtendable, ExpressibleByDictionary {
    
    public typealias Key = MediaType
    
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
        let container = try decoder.container(keyedBy: StringKey<Key>.self)
        let pairs = try container.allKeys.map {
            try ($0.value, container.decode(Value.self, forKey: $0))
        }
        self = Self.init(
            Dictionary(pairs) { _, second in
                second
            }
        )
    }
    
    public subscript(_ key: Key) -> Value? {
        get { value[key] }
        set { value[key] = newValue }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: StringKey<Key>.self)
        for (key, object) in value {
            try container.encode(object, forKey: StringKey(key))
        }
    }
}
