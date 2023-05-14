import Foundation

/// The Schema Object allows the definition of input and output data types. These types can be objects, but also primitives and arrays. This object is a superset of the JSON Schema Specification Draft 2020-12.
///
/// For more information about the properties, see JSON Schema Core and JSON Schema Validation.
///
/// Unless stated otherwise, the property definitions follow those of JSON Schema and do not add any additional semantics. Where JSON Schema indicates that behavior is defined by the application (e.g. for annotations), OAS also defers the definition of semantics to the application consuming the OpenAPI document.
public struct SchemaObject: Equatable, Codable, SpecificationExtendable {
    
    public var description: String?
    public var externalDocs: ExternalDocumentationObject?
    public var type: SchemaType
    public var example: AnyValue?
    
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
        case description
        case externalDocs
		case example
        
        case oneOf
        case allOf
        case anyOf
    }
    
    public init(
        _ type: SchemaType,
        example: AnyValue? = nil,
        description: String? = nil,
        externalDocs: ExternalDocumentationObject? = nil
    ) {
        self.description = description
        self.externalDocs = externalDocs
        self.example = example
        self.type = type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        description = try? container.decodeIfPresent(String.self, forKey: .description)
        externalDocs = try? container.decodeIfPresent(ExternalDocumentationObject.self, forKey: .externalDocs)
		example = try container.decodeIfPresent(AnyValue.self, forKey: .example)
//		specificationExtensions = try SpecificationExtensions(from: decoder)
        let dataType = try container.decodeIfPresent(DataType.self, forKey: .type)
        
        switch dataType {
        case .array:
            let items = try container.decode(ReferenceOr<SchemaObject>.self, forKey: .items)
            type = .array(items)
            
        case .object:
            let properties = try container.decodeIfPresent([String: ReferenceOr<SchemaObject>].self, forKey: .properties)
            let xml = try container.decodeIfPresent(XMLObject.self, forKey: .xml)
            let required = try container.decodeIfPresent(Set<String>.self, forKey: .required)
            let additionalProperties = try container.decodeIfPresent(ReferenceOr<SchemaObject>.self, forKey: .additionalProperties)
            type = .object(
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
                type = .composite(
                    composition,
                    objects,
                    discriminator: discriminator
                )
            } else {
                type = .any
            }
            
        case let .some(primitiveType):
            let dataType = PrimitiveDataType(rawValue: primitiveType.rawValue) ?? .string
            if let allCases = try container.decodeIfPresent([String].self, forKey: .enum) {
                type = .enum(dataType, allCases: allCases)
            } else {
                let format = try container.decodeIfPresent(DataFormat.self, forKey: .format)
                let pattern = try container.decodeIfPresent(String.self, forKey: .pattern)
                type = .primitive(dataType, format: format, pattern: pattern)
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
//		try specificationExtensions?.encode(to: encoder)

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(externalDocs, forKey: .externalDocs)
		try container.encodeIfPresent(example, forKey: .example)
        switch type {
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
            if let properties {
                var nested = container.nestedContainer(keyedBy: StringKey<String>.self, forKey: .properties)
                try properties.sorted { $0.key < $1.key }.forEach { key, value in
                    try nested.encode(value, forKey: StringKey(key))
                }
            }
            try container.encodeIfPresent(required?.sorted(), forKey: .required)
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

public indirect enum SchemaType: Equatable, SpecificationExtendable {
    
    case any
    
    case primitive(
        PrimitiveDataType,
        format: DataFormat? = nil,
        pattern: String? = nil
    )
    
    case object(
        [String: ReferenceOr<SchemaObject>]? = nil,
        required: Set<String>? = nil,
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
}

public protocol ExpressibleBySchemaObject {

	init(schemaObject: SchemaObject)
}

extension SchemaObject: ExpressibleBySchemaObject {

	public init(schemaObject: SchemaObject) {
		self = schemaObject
	}
}

extension ReferenceOr<SchemaObject>: ExpressibleBySchemaObject {

	public init(schemaObject: SchemaObject) {
		self = .value(schemaObject)
	}
}

public extension ExpressibleBySchemaObject {
    
    static func one(
        of types: ReferenceOr<SchemaObject>...,
        discriminator: DiscriminatorObject? = nil,
        description: String? = nil,
        externalDocs: ExternalDocumentationObject? = nil
    ) -> Self {
        Self(
            schemaObject: SchemaObject(
                .composite(.oneOf, types, discriminator: discriminator),
                description: description,
                externalDocs: externalDocs
            )
        )
    }
    
    static func all(
        of types: ReferenceOr<SchemaObject>...,
        discriminator: DiscriminatorObject? = nil,
        description: String? = nil,
        externalDocs: ExternalDocumentationObject? = nil
    ) -> Self {
        Self(
            schemaObject: SchemaObject(
                .composite(.allOf, types, discriminator: discriminator),
                description: description,
                externalDocs: externalDocs
            )
        )
    }
    
    static func any(
        of types: ReferenceOr<SchemaObject>...,
        discriminator: DiscriminatorObject? = nil,
        description: String? = nil,
        externalDocs: ExternalDocumentationObject? = nil
    ) -> Self {
        Self(
            schemaObject: SchemaObject(
                .composite(.anyOf, types, discriminator: discriminator),
                description: description,
                externalDocs: externalDocs
            )
        )
    }
    
    static var any: Self {
        Self(schemaObject: SchemaObject(.any))
    }
    
    static func primitive(
        _ type: PrimitiveDataType,
        format: DataFormat? = nil,
        pattern: String? = nil,
        description: String? = nil,
        externalDocs: ExternalDocumentationObject? = nil
    ) -> Self {
        Self(
            schemaObject: SchemaObject(
                .primitive(type, format: format, pattern: pattern),
                description: description,
                externalDocs: externalDocs
            )
        )
    }
    
    static func object(
        properties: [String: ReferenceOr<SchemaObject>],
        required: Set<String> = [],
        xml: XMLObject? = nil,
        description: String? = nil,
        externalDocs: ExternalDocumentationObject? = nil
    ) -> Self {
        Self(
            schemaObject: SchemaObject(
                .object(properties.nilIfEmpty, required: required.nilIfEmpty, xml: xml),
                description: description,
                externalDocs: externalDocs
            )
        )
    }
    
    static func dictionary(
        of additionalProperties: ReferenceOr<SchemaObject>,
        xml: XMLObject? = nil,
        description: String? = nil,
        externalDocs: ExternalDocumentationObject? = nil
    ) -> Self {
        Self(
            schemaObject: SchemaObject(
                .object(additionalProperties: additionalProperties, xml: xml),
                description: description,
                externalDocs: externalDocs
            )
        )
    }
    
    static func array(
        of type: ReferenceOr<SchemaObject>,
        description: String? = nil,
        externalDocs: ExternalDocumentationObject? = nil
    ) -> Self {
        Self(
            schemaObject: SchemaObject(
                .array(type),
                description: description,
                externalDocs: externalDocs
            )
        )
    }
    
    static func `enum`(
        of type: PrimitiveDataType = .string,
        cases: [String],
        description: String? = nil,
        externalDocs: ExternalDocumentationObject? = nil
    ) -> Self {
        Self(
            schemaObject: SchemaObject(
                .enum(type, allCases: cases),
                description: description,
                externalDocs: externalDocs
            )
        )
    }
    
    static var string: Self { primitive(.string) }
    static func string(format: DataFormat, description: String? = nil) -> Self {
        .primitive(.string, format: format, description: description)
    }
    static var number: Self { .primitive(.number) }
    static var integer: Self { .primitive(.integer, format: .int64) }
    static var float: Self { .primitive(.number, format: .float) }
    static var decimal: Self { .primitive(.number, format: .decimal) }
    static var double: Self { .primitive(.number, format: .double) }
    static var boolean: Self { .primitive(.boolean) }
    static var uuid: Self { .primitive(.string, format: .uuid) }
    static var uri: Self { .primitive(.string, format: .uri) }
}

extension SchemaObject: ExpressibleByDictionary {
    
    public typealias Key = String
    public typealias Value = ReferenceOr<SchemaObject>
    
    public init(dictionaryElements elements: [(String, ReferenceOr<SchemaObject>)]) {
        self = .object(
            properties: Dictionary(elements) { _, s in s }
        )
    }
    
    public subscript(key: String) -> ReferenceOr<SchemaObject>? {
        get {
            if case let .object(dictionary, _, _, _) = type {
                return dictionary?[key]
            }
            return nil
        }
        set {
            if case .object(var dictionary, let required, let additionalProperties, let xml) = type {
                dictionary?[key] = newValue
                type = .object(dictionary, required: required, additionalProperties: additionalProperties, xml: xml)
            }
        }
    }
}

extension SchemaObject {
    
    var isReferenceable: Bool {
        switch type {
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
		case let .value(object):
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
    
    static func decode(
        _ type: Decodable.Type,
        dateFormat: DateEncodingFormat = .default,
        into schemas: inout [String: ReferenceOr<SchemaObject>]
    ) throws {
        let encoder = SchemeEncoder(dateFormat: dateFormat)
        try encoder.decode(type, into: &schemas)
    }
}
