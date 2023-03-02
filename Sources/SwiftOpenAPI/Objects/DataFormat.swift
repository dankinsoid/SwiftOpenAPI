import Foundation

public struct DataFormat: RawRepresentable, ExpressibleByStringLiteral, LosslessStringConvertible, Hashable, Codable {
    
    public var rawValue: String
    public var description: String { rawValue }
    
    public init(_ description: String) {
        self.rawValue = description
    }
    
    public init(rawValue: String) {
        self.init(rawValue)
    }
    
    public init(stringLiteral value: String) {
        self.init(value)
    }
    
    public init(from decoder: Decoder) throws {
        try self.init(String(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}

public extension DataFormat {
    
    static var email: DataFormat = "email"
    static var uuid: DataFormat = "uuid"
    static var uri: DataFormat = "uri"
    static var hostname: DataFormat = "hostname"
    static var ipv4: DataFormat = "ipv4"
    static var ipv6: DataFormat = "ipv6"
    
    /// full-date notation as defined by RFC 3339, section 5.6, for example, 2017-07-21
    static var date: DataFormat = "date"
    
    /// the date-time notation as defined by RFC 3339, section 5.6, for example, 2017-07-21T17:32:28Z
    static var dateTime: DataFormat = "date-time"
    
    /// a hint to UIs to mask the input
    static var password: DataFormat = "password"
    
    /// base64-encoded characters, for example, U3dhZ2dlciByb2Nrcw==
    static var byte: DataFormat = "byte"
    
    /// binary data, used to describe files
    static var binary: DataFormat = "binary"
}
