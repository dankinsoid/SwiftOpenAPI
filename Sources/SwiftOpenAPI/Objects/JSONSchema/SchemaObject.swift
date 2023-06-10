import Foundation

/// The Schema Object allows the definition of input and output data types. These types can be objects, but also primitives and arrays. This object is a superset of the JSON Schema Specification Draft 2020-12.
///
/// For more information about the properties, see JSON Schema Core and JSON Schema Validation.
///
/// Unless stated otherwise, the property definitions follow those of JSON Schema and do not add any additional semantics. Where JSON Schema indicates that behavior is defined by the application (e.g. for annotations), OAS also defers the definition of semantics to the application consuming the OpenAPI document.
public struct SchemaObject: Equatable, Codable, SpecificationExtendable {

	public var title: String?
	public var description: String?
	public var deprecated: Bool?
	public var format: DataFormat?
	public var xml: XMLObject?
	public var externalDocs: ExternalDocumentationObject?

	public var `default`: AnyValue?
	public var `enum`: [AnyValue]? {
		didSet {
			checkNullableEnum()
		}
	}

	public var readOnly: Bool?
	public var writeOnly: Bool?

	public var specificationExtensions: SpecificationExtensions?
	public var context: SchemaContexts?

	public var nullable: Bool? {
		didSet {
			checkNullableEnum()
		}
	}

	public var example: AnyValue? {
		didSet {
			if example != nil {
				examples = nil
			}
		}
	}

	public var examples: OrderedDictionary<String, ReferenceOr<ExampleObject>>? {
		didSet {
			if examples != nil {
				example = nil
			}
		}
	}

	public init(
		title: String? = nil,
		description: String? = nil,
		deprecated: Bool? = nil,
		format: DataFormat? = nil,
		xml: XMLObject? = nil,
		externalDocs: ExternalDocumentationObject? = nil,
		default: AnyValue? = nil,
		enum: [AnyValue]? = nil,
		nullable: Bool? = nil,
		readOnly: Bool? = nil,
		writeOnly: Bool? = nil,
		specificationExtensions: SpecificationExtensions? = nil,
		example: AnyValue? = nil,
		examples: OrderedDictionary<String, ReferenceOr<ExampleObject>>? = nil,
		context: SchemaContexts? = nil
	) {
		self.title = title
		self.description = description
		self.deprecated = deprecated
		self.xml = xml
		self.format = format
		self.externalDocs = externalDocs
		self.default = `default`
		self.enum = `enum`
		self.nullable = nullable
		self.readOnly = readOnly
		self.writeOnly = writeOnly
		self.specificationExtensions = specificationExtensions
		self.context = context
		self.example = examples == nil ? example : nil
		self.examples = examples
	}

	public init(from decoder: Decoder) throws {
		specificationExtensions = try SpecificationExtensions(from: decoder)

		let container = try decoder.container(keyedBy: CodingKeys.self)

		title = try container.decodeIfPresent(String.self, forKey: .title)
		description = try container.decodeIfPresent(String.self, forKey: .description)
		xml = try container.decodeIfPresent(XMLObject.self, forKey: .xml)
		externalDocs = try container.decodeIfPresent(ExternalDocumentationObject.self, forKey: .externalDocs)
		format = try container.decodeIfPresent(DataFormat.self, forKey: .format)
		example = try container.decodeIfPresent(AnyValue.self, forKey: .example)
		examples = try container.decodeIfPresent(OrderedDictionary<String, ReferenceOr<ExampleObject>>.self, forKey: .examples)
		deprecated = try container.decodeIfPresent(Bool.self, forKey: .deprecated)
		`default` = try container.decodeIfPresent(AnyValue.self, forKey: .default)
		`enum` = try container.decodeIfPresent([AnyValue].self, forKey: .enum)
		nullable = try container.decodeIfPresent(Bool.self, forKey: .nullable)
		readOnly = try container.decodeIfPresent(Bool.self, forKey: .readOnly)
		writeOnly = try container.decodeIfPresent(Bool.self, forKey: .writeOnly)

		let type = try container.decodeIfPresent(DataType.self, forKey: .type)
		switch type {
		case .array:
			context = try .array(ArrayContext(from: decoder))
		case .object:
			context = try .object(ObjectContext(from: decoder))
		case .boolean:
			context = try .boolean(BooleanContext(from: decoder))
		case .integer:
			context = try .integer(NumberContext(from: decoder))
		case .number:
			context = try .number(NumberContext(from: decoder))
		case .string:
			context = try .string(StringContext(from: decoder))
		case .none:
			let composition = try CompositionContext(from: decoder)
			if composition != .invalid {
				context = .composition(composition)
			}
		}
	}

	public func encode(to encoder: Encoder) throws {
		try specificationExtensions?.encode(to: encoder)

		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(context?.type, forKey: .type)
		try container.encodeIfPresent(title, forKey: .title)
		try container.encodeIfPresent(description, forKey: .description)
		try container.encodeIfPresent(format, forKey: .format)
		try container.encodeIfPresent(xml, forKey: .xml)
		try container.encodeIfPresent(externalDocs, forKey: .externalDocs)
		try container.encodeIfPresent(examples?.nilIfEmpty, forKey: .examples)
		try container.encodeIfPresent(example, forKey: .example)
		try container.encodeIfPresent(`default`, forKey: .default)
		try container.encodeIfPresent(deprecated?.nilIfFalse, forKey: .deprecated)
		try container.encodeIfPresent(`enum`, forKey: .enum)
		try container.encodeIfPresent(nullable?.nilIfFalse, forKey: .nullable)
		try container.encodeIfPresent(readOnly?.nilIfFalse, forKey: .readOnly)
		try container.encodeIfPresent(writeOnly?.nilIfFalse, forKey: .writeOnly)

		switch context {
		case .none:
			break
		case let .array(context):
			try context.encode(to: encoder)
		case let .object(context):
			try context.encode(to: encoder)
		case let .boolean(context):
			try context.encode(to: encoder)
		case let .integer(context):
			try context.encode(to: encoder)
		case let .number(context):
			try context.encode(to: encoder)
		case let .string(context):
			try context.encode(to: encoder)
		case let .composition(context):
			try context.encode(to: encoder)
		}
	}

	public enum CodingKeys: String, CodingKey {

		case type
		case title
		case description
		case format
		case examples
		case deprecated
		case xml
		case externalDocs
		case example
		case `default`
		case `enum`
		case nullable
		case readOnly
		case writeOnly
	}
}

private extension SchemaObject {

	mutating func checkNullableEnum() {
		let nullValue: AnyValue = .null
		if nullable == true {
			if var allValues = `enum`, !allValues.contains(nullValue) {
				allValues.append(nullValue)
				self.enum = allValues
			}
		} else if var allValues = `enum`, let i = allValues.firstIndex(of: nullValue) {
			allValues.remove(at: i)
			self.enum = allValues
		}
	}
}
