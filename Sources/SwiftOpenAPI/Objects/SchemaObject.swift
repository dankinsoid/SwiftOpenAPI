import Foundation

// TODO - description, externalDocs

/// The Schema Object allows the definition of input and output data types. These types can be objects, but also primitives and arrays. This object is a superset of the JSON Schema Specification Draft 2020-12.
///
/// For more information about the properties, see JSON Schema Core and JSON Schema Validation.
///
/// Unless stated otherwise, the property definitions follow those of JSON Schema and do not add any additional semantics. Where JSON Schema indicates that behavior is defined by the application (e.g. for annotations), OAS also defers the definition of semantics to the application consuming the OpenAPI document.
public indirect enum SchemaObject: Equatable, Codable, SpecificationExtendable {
    
    case any
    
    case primitive(
        PrimitiveDataType,
        format: DataFormat? = nil,
        pattern: String? = nil
    )
    
    case object(
        [String: ReferenceOr<SchemaObject>]?,
        required: Set<String>?,
        additionalProperties: ReferenceOr<SchemaObject>? = nil,
        xml: XMLObject? = nil
    )
    
    case array(
        ReferenceOr<SchemaObject>
    )
    
    case composite(
        CompositeType,
        [ReferenceOr<SchemaObject>],
        discriminator: DiscriminatorObject?
    )
    
    case `enum`(
        PrimitiveDataType,
        allCases: [String]
    )
    
    public enum CodingKeys: String, CodingKey {
        
        case type
        case items
        case required
        case format
        case properties
        case pattern
        case discriminator
        case xml
        case `enum`
        case additionalProperties
        
        case oneOf
        case allOf
        case anyOf
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decodeIfPresent(DataType.self, forKey: .type)
        
        switch type {
        case .array:
            let items = try container.decode(ReferenceOr<SchemaObject>.self, forKey: .items)
            self = .array(items)
            
        case .object:
            let properties = try container.decodeIfPresent([String: ReferenceOr<SchemaObject>].self, forKey: .properties)
            let xml = try container.decodeIfPresent(XMLObject.self, forKey: .xml)
        		let required = try container.decodeIfPresent(Set<String>.self, forKey: .required)
        		let additionalProperties = try container.decodeIfPresent(ReferenceOr<SchemaObject>.self, forKey: .additionalProperties)
            self = .object(
                properties,
                required: required,
                additionalProperties: additionalProperties,
                xml: xml
            )
            
        case .none:
            let compositionKey = Set(container.allKeys).intersection([.oneOf, .allOf, .anyOf]).first
            
            if let compositionKey, let composition = CompositeType(rawValue: compositionKey.rawValue) {
                let discriminator = try container.decodeIfPresent(DiscriminatorObject.self, forKey: .discriminator)
                let objects = try container.decode([ReferenceOr<SchemaObject>].self, forKey: compositionKey)
                self = .composite(
                    composition,
                    objects,
                    discriminator: discriminator
                )
            } else {
                self = .any
            }
            
        case let .some(type):
            let dataType = PrimitiveDataType(rawValue: type.rawValue) ?? .string
            if let allCases = try container.decodeIfPresent([String].self, forKey: .enum) {
                self = .enum(dataType, allCases: allCases)
            } else {
                let format = try container.decodeIfPresent(DataFormat.self, forKey: .format)
                let pattern = try container.decodeIfPresent(String.self, forKey: .pattern)
                self = .primitive(dataType, format: format, pattern: pattern)
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .any:
            break
            
        case let .primitive(type, format, pattern):
            try container.encodeIfPresent(type, forKey: .type)
            try container.encodeIfPresent(format, forKey: .format)
            try container.encodeIfPresent(pattern, forKey: .pattern)
            
        case let .object(
            properties,
            required,
            additionalProperties,
            xml
        ):
            try container.encodeIfPresent(DataType.object, forKey: .type)
            try container.encodeIfPresent(xml, forKey: .xml)
            try container.encodeIfPresent(properties, forKey: .properties)
            try container.encodeIfPresent(required, forKey: .required)
            try container.encodeIfPresent(additionalProperties, forKey: .additionalProperties)
            
        case let .array(schemaObject):
            try container.encodeIfPresent(DataType.array, forKey: .type)
            try container.encode(schemaObject, forKey: .items)
            
        case let .composite(composite, items, discriminator):
            try container.encodeIfPresent(discriminator, forKey: .type)
            try container.encode(items, forKey: CodingKeys(rawValue: composite.rawValue) ?? .oneOf)
            
        case let .enum(type, allCases):
            try container.encode(type, forKey: .type)
            try container.encode(allCases, forKey: .enum)
        }
    }
}

public protocol ExpressibleBySchemaObject {
    
    init(schemaObject: SchemaObject)
}

extension SchemaObject: ExpressibleBySchemaObject {
    
    public init(schemaObject: SchemaObject) {
        self = schemaObject
    }
}

extension ReferenceOr: ExpressibleBySchemaObject where Object: ExpressibleBySchemaObject {
    
    public init(schemaObject: SchemaObject) {
        self = .value(Object(schemaObject: schemaObject))
    }
}

public extension ExpressibleBySchemaObject {
    
    static func oneOf(
        _ types: ReferenceOr<SchemaObject>...,
        discriminator: DiscriminatorObject? = nil
    ) -> Self {
        Self(
            schemaObject: .composite(.oneOf, types, discriminator: discriminator)
        )
    }
    
    static func allOf(
        _ types: ReferenceOr<SchemaObject>...,
        discriminator: DiscriminatorObject? = nil
    ) -> Self {
        Self(
            schemaObject: .composite(.allOf, types, discriminator: discriminator)
        )
    }
    
    static func anyOf(
        _ types: ReferenceOr<SchemaObject>...,
        discriminator: DiscriminatorObject? = nil
    ) -> Self {
        Self(
            schemaObject: .composite(.anyOf, types, discriminator: discriminator)
        )
    }
    
    static var string: Self { Self(schemaObject: .primitive(.string)) }
    static var number: Self { Self(schemaObject: .primitive(.number)) }
    static var integer: Self { Self(schemaObject: .primitive(.integer)) }
    static var boolean: Self { Self(schemaObject: .primitive(.boolean)) }
}

extension SchemaObject: ExpressibleByDictionary {
    
    public typealias Key = String
    public typealias Value = ReferenceOr<SchemaObject>
    
    public init(dictionaryElements elements: [(String, ReferenceOr<SchemaObject>)]) {
        self = .object(
            Dictionary(elements) { _, s in s },
            required: nil,
            additionalProperties: nil,
            xml: nil
        )
    }
    
    public subscript(key: String) -> ReferenceOr<SchemaObject>? {
        get {
            if case let .object(dictionary, _, _, _) = self {
                return dictionary?[key]
            }
            return nil
        }
        set {
            if case .object(var dictionary, let required, let additionalProperties, let xml) = self {
                dictionary?[key] = newValue
                self = .object(dictionary, required: required, additionalProperties: additionalProperties, xml: xml)
            }
        }
    }
}

extension SchemaObject {
    
    var isReferenceable: Bool {
        switch self {
        case .any, .array, .primitive:
            return false
        case .composite, .enum:
            return true
        case let .object(_, _, additional, _):
            return additional == nil
        }
    }
}

extension ReferenceOr<SchemaObject> {
    
    var isReferenceable: Bool {
        switch self {
        case .value(let object):
            return object.isReferenceable
        case .ref:
            return false
        }
    }
}

public extension SchemaObject {
    
    static func encode(
        _ value: Encodable,
        dateFormat: DateEncodingFormat = .default,
        into schemas: inout [String: ReferenceOr<SchemaObject>]
    ) throws {
        let encoder = SchemeEncoder(dateFormat: dateFormat)
        try encoder.encode(value, into: &schemas)
    }
}
