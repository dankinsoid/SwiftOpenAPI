import Foundation

/// When request bodies or response payloads may be one of a number of different schemas, a discriminator object can be used to aid in serialization, deserialization, and validation. The discriminator is a specific object in a schema which is used to inform the consumer of the document of an alternative schema based on the value associated with it.
///
/// When using the discriminator, inline schemas will not be considered.
public struct DiscriminatorObject: Codable, Equatable, SpecificationExtendable {
    
    /// The name of the property in the payload that will hold the discriminator value.
    public var propertyName: String
    
    /// An object to hold mappings between payload values and schema names or references.
    public var mapping: [String: String]?
    
    public init(propertyName: String, mapping: [String: String]? = nil) {
        self.propertyName = propertyName
        self.mapping = mapping
    }
}
