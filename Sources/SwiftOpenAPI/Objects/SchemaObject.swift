import Foundation

/// The Schema Object allows the definition of input and output data types. These types can be objects, but also primitives and arrays. This object is a superset of the JSON Schema Specification Draft 2020-12.
///
/// For more information about the properties, see JSON Schema Core and JSON Schema Validation.
///
/// Unless stated otherwise, the property definitions follow those of JSON Schema and do not add any additional semantics. Where JSON Schema indicates that behavior is defined by the application (e.g. for annotations), OAS also defers the definition of semantics to the application consuming the OpenAPI document.
public struct SchemaObject: Equatable, Codable, SpecificationExtendable {

	public var description: String?

	/// Additional external documentation for this schema.
	public var externalDocs: ExternalDocumentationObject?

	/// A free-form property to include an example of an instance for this schema.
	/// To represent examples that cannot be naturally represented in JSON or YAML, a string value can be used to contain the example with escaping where necessary.
	/// Deprecated: The example property has been deprecated in favor of the JSON Schema examples keyword. Use of example is discouraged, and later versions of this specification may remove it.
	public var example: AnyValue?
	public var schema: Schema
	public var specificationExtensions: SpecificationExtensions? = nil

	public enum CodingKeys: String, CodingKey {

		case description
		case externalDocs
		case example

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

	public init(
		schema: SchemaObject.Schema,
		description: String? = nil,
		externalDocs: ExternalDocumentationObject? = nil,
		example: AnyValue? = nil,
		specificationExtensions: SpecificationExtensions? = nil
	) {
		self.description = description
		self.externalDocs = externalDocs
		self.example = example
		self.schema = schema
		self.specificationExtensions = specificationExtensions
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let type = try container.decodeIfPresent(DataType.self, forKey: .type)

		description = try container.decodeIfPresent(String.self, forKey: .description)
		externalDocs = try container.decodeIfPresent(ExternalDocumentationObject.self, forKey: .externalDocs)
		example = try container.decodeIfPresent(AnyValue.self, forKey: .example)
		specificationExtensions = try SpecificationExtensions(from: decoder)

		switch type {
		case .array:
			let items = try container.decode(ReferenceOr<SchemaObject>.self, forKey: .items)
			schema = .array(items)

		case .object:
			let properties = try container.decodeIfPresent([String: ReferenceOr<SchemaObject>].self, forKey: .properties)
			let xml = try container.decodeIfPresent(XMLObject.self, forKey: .xml)
			let required = try container.decodeIfPresent(Set<String>.self, forKey: .required)
			let additionalProperties = try container.decodeIfPresent(ReferenceOr<SchemaObject>.self, forKey: .additionalProperties)
			schema = .object(
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
				schema = .composite(
					composition,
					objects,
					discriminator: discriminator
				)
			} else {
				schema = .any
			}

		case let .some(type):
			let dataType = PrimitiveDataType(rawValue: type.rawValue) ?? .string
			if let allCases = try container.decodeIfPresent([String].self, forKey: .enum) {
				schema = .enum(dataType, allCases: allCases)
			} else {
				let format = try container.decodeIfPresent(DataFormat.self, forKey: .format)
				let pattern = try container.decodeIfPresent(String.self, forKey: .pattern)
				schema = .primitive(dataType, format: format, pattern: pattern)
			}
		}
	}

	public func encode(to encoder: Encoder) throws {
		try specificationExtensions?.encode(to: encoder)

		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encodeIfPresent(description, forKey: .description)
		try container.encodeIfPresent(externalDocs, forKey: .externalDocs)
		try container.encodeIfPresent(example, forKey: .example)

		switch schema {
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

public extension SchemaObject {
	indirect enum Schema: Equatable {
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

extension ReferenceOr<SchemaObject>: ExpressibleBySchemaObject {

	public init(schemaObject: SchemaObject) {
		self = .value(schemaObject)
	}
}

public extension ExpressibleBySchemaObject {

	static var any: Self { Self(schemaObject: SchemaObject(schema: .any)) }

	static func primitive(
		_ type: PrimitiveDataType,
		format: DataFormat? = nil,
		pattern: String? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				schema: .primitive(type, format: format, pattern: pattern)
			)
		)
	}

	static func object(
		_ properties: [String: ReferenceOr<SchemaObject>]?,
		required: Set<String>?,
		additionalProperties: ReferenceOr<SchemaObject>? = nil,
		xml: XMLObject? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				schema: .object(properties, required: required, additionalProperties: additionalProperties, xml: xml)
			)
		)
	}

	static func dictionary(
		of properties: ReferenceOr<SchemaObject>
	) -> Self {
		.object(nil, required: nil, additionalProperties: properties)
	}

	static func array(of item: ReferenceOr<SchemaObject>) -> Self {
		Self(
			schemaObject: SchemaObject(
				schema: .array(item)
			)
		)
	}

	static func `enum`(
		of type: PrimitiveDataType = .string,
		cases allCases: [String]
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				schema: .enum(type, allCases: allCases)
			)
		)
	}
	
	static func `enum`<T: CaseIterable & RawRepresentable>(
		_ type: T.Type
	) -> Self where T.RawValue == String {
		Self(
			schemaObject: SchemaObject(
				schema: .enum(.string, allCases: T.allCases.map(\.rawValue))
			)
		)
	}

	static func one(
		of types: ReferenceOr<SchemaObject>...,
		discriminator: DiscriminatorObject? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				schema: .composite(.oneOf, types, discriminator: discriminator)
			)
		)
	}

	static func all(
		of types: ReferenceOr<SchemaObject>...,
		discriminator: DiscriminatorObject? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				schema: .composite(.allOf, types, discriminator: discriminator)
			)
		)
	}

	static func any(
		of types: ReferenceOr<SchemaObject>...,
		discriminator: DiscriminatorObject? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				schema: .composite(.anyOf, types, discriminator: discriminator)
			)
		)
	}

	static var uri: Self { Self(schemaObject: .primitive(.string, format: .uri)) }
	static var uuid: Self { Self(schemaObject: .primitive(.string, format: .uuid)) }
	static var dateTime: Self { Self(schemaObject: .primitive(.string, format: .dateTime)) }
	static var date: Self { Self(schemaObject: .primitive(.string, format: .date)) }
	static var string: Self { Self(schemaObject: .primitive(.string)) }
	static var number: Self { Self(schemaObject: .primitive(.number)) }
	static var double: Self { Self(schemaObject: .primitive(.number, format: .double)) }
	static var float: Self { Self(schemaObject: .primitive(.number, format: .float)) }
	static var integer: Self { Self(schemaObject: .primitive(.integer, format: .int64)) }
	static var boolean: Self { Self(schemaObject: .primitive(.boolean)) }
	static func integer(_ format: DataFormat) -> Self { Self(schemaObject: .primitive(.integer, format: format)) }
	static func string(_ format: DataFormat) -> Self { Self(schemaObject: .primitive(.string, format: format)) }
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
			if case let .object(dictionary, _, _, _) = schema {
				return dictionary?[key]
			}
			return nil
		}
		set {
			if case .object(var dictionary, let required, let additionalProperties, let xml) = schema {
				dictionary?[key] = newValue
				self = .object(dictionary, required: required, additionalProperties: additionalProperties, xml: xml)
			}
		}
	}
}

extension SchemaObject {

	var isReferenceable: Bool {
		switch schema {
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
}
