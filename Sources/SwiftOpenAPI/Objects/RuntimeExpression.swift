import Foundation

public struct RuntimeExpression: Codable, Hashable, ExpressibleByStringInterpolation, RawRepresentable, CodingKey {
    
    public var rawValue: String
    
    public var stringValue: String { rawValue }
    public var intValue: Int? { nil }
    
    public var surrounded: String {
        "{\(rawValue)}"
    }
    
    public init(rawValue: String) {
        self.rawValue = rawValue.trimmingCharacters(in: ["{", "}"])
    }
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
    
    public init(stringInterpolation value: DefaultStringInterpolation) {
        self.init(rawValue: String(stringInterpolation: value))
    }
    
    public init?(stringValue: String) {
        self.init(rawValue: stringValue)
    }
    
    public init?(intValue: Int) {
        return nil
    }
    
    public init(from decoder: Decoder) throws {
        try self.init(rawValue: String(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try surrounded.encode(to: encoder)
    }
}
