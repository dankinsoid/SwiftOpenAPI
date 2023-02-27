import Foundation

/// The Schema Object allows the definition of input and output data types. These types can be objects, but also primitives and arrays. This object is a superset of the JSON Schema Specification Draft 2020-12.
///
/// For more information about the properties, see JSON Schema Core and JSON Schema Validation.
///
/// Unless stated otherwise, the property definitions follow those of JSON Schema and do not add any additional semantics. Where JSON Schema indicates that behavior is defined by the application (e.g. for annotations), OAS also defers the definition of semantics to the application consuming the OpenAPI document.
public struct SchemaObject: Codable, Equatable, SpecificationExtendable {
    
    public var type: String?
    
    public var format: String?
    
    public var objectType: SchemaObjectType
    
    /// Adds support for polymorphism. The discriminator is an object name that is used to differentiate between other schemas which may satisfy the payload description. See Composition and Inheritance for more details.
    public var discriminator: DiscriminatorObject?
    
    /// This MAY be used only on properties schemas. It has no effect on root schemas. Adds additional metadata to describe the XML representation of this property.
    public var xml: XMLObject?
    
    /// Additional external documentation for this schema.
    public var externalDocs: ExternalDocumentationObject?
    
    /// A free-form property to include an example of an instance for this schema. To represent examples that cannot be naturally represented in JSON or YAML, a string value can be used to contain the example with escaping where necessary.
    
    @available(*, deprecated, message: "The example property has been deprecated in favor of the JSON Schema examples keyword. Use of example is discouraged, and later versions of this specification may remove it.")
    public var example: AnyValue?
    
    public enum CodingKeys: String, CodingKey {
        
        case type
        case format
        case items
        case required
        case properties
        case example
        case discriminator
        case xml
        case externalDocs
        case additionalProperties
    }
    
    public init(
        type: String? = nil,
        format: String? = nil,
        objectType: SchemaObjectType,
        discriminator: DiscriminatorObject? = nil,
        xml: XMLObject? = nil,
        externalDocs: ExternalDocumentationObject? = nil
    ) {
        self.type = type
        self.format = format
        self.objectType = objectType
        self.discriminator = discriminator
        self.xml = xml
        self.externalDocs = externalDocs
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        format = try container.decodeIfPresent(String.self, forKey: .format)
        discriminator = try container.decodeIfPresent(DiscriminatorObject.self, forKey: .discriminator)
        xml = try container.decodeIfPresent(XMLObject.self, forKey: .xml)
        externalDocs = try container.decodeIfPresent(ExternalDocumentationObject.self, forKey: .externalDocs)
        example = try container.decodeIfPresent(AnyValue.self, forKey: .example)
        
        if let properties = try container.decodeIfPresent([String: ReferenceOr<SchemaObject>].self, forKey: .properties) {
            objectType =  try .object(
                properties,
                required: container.decodeIfPresent([String].self, forKey: .required),
                additionalProperties: container.decodeIfPresent(ReferenceOr<SchemaObject>.self, forKey: .additionalProperties)
            )
        } else if let items = try container.decodeIfPresent(ReferenceOr<SchemaObject>.self, forKey: .items) {
            objectType = .array(items)
        } else {
            objectType = .primitive
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(discriminator, forKey: .discriminator)
        try container.encodeIfPresent(format, forKey: .format)
        try container.encodeIfPresent(xml, forKey: .xml)
        try container.encodeIfPresent(externalDocs, forKey: .externalDocs)
        try container.encodeIfPresent(example, forKey: .example)
        
        switch objectType {
        case .primitive:
            break
            
        case let .object(properties, required, additionalProperties):
            try container.encode(properties, forKey: .properties)
            try container.encodeIfPresent(required, forKey: .required)
            try container.encodeIfPresent(additionalProperties, forKey: .additionalProperties)
            
        case let .array(schemaObject):
            try container.encode(schemaObject, forKey: .items)
        }
    }
}

public indirect enum SchemaObjectType: Equatable {
    
    case primitive
    case object([String: ReferenceOr<SchemaObject>], required: [String]?, additionalProperties: ReferenceOr<SchemaObject>?)
    case array(ReferenceOr<SchemaObject>)
}
