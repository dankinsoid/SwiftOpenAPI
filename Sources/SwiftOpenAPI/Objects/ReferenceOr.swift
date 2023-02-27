import Foundation

public enum ReferenceOr<Object: Codable & Equatable>: Equatable, Codable {
    
    case object(Object)
    case reference(ReferenceObject)
    
    public init(from decoder: Decoder) throws {
        do {
            self = try .reference(ReferenceObject(from: decoder))
        } catch {
            self = try .object(Object(from: decoder))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .object(object):
            try object.encode(to: encoder)
        case let .reference(referenceObject):
            try referenceObject.encode(to: encoder)
        }
    }
}
