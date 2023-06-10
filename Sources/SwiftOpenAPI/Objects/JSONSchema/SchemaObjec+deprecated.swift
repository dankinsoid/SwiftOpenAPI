import Foundation

public extension SchemaObject {

	@available(*, deprecated, message: "Use init with SchemaContexts instead")
	init(
		_ type: SchemaType,
		title: String? = nil,
		default: AnyValue? = nil,
		example: AnyValue? = nil,
		description: String? = nil,
		nullable: Bool? = nil,
		readOnly: Bool? = nil,
		writeOnly: Bool? = nil,
		deprecated: Bool? = nil,
		externalDocs: ExternalDocumentationObject? = nil,
		specificationExtensions: SpecificationExtensions? = nil
	) {
		self.title = title
		self.default = `default`
		self.description = description
		self.externalDocs = externalDocs
		self.example = example
		self.nullable = nullable
		self.readOnly = readOnly
		self.writeOnly = writeOnly
		self.deprecated = deprecated
		self.specificationExtensions = specificationExtensions
		set(type: type)
	}

	@available(*, deprecated, message: "Use contexts")
	var type: SchemaType {
		get {
			switch context {
			case .none:
				return .any
			case let .array(context):
				return .array(context.items)
			case let .object(context):
				let additional: ReferenceOr<SchemaObject>?
				switch context.additionalProperties {
				case let .schema(ref): additional = ref
				default: additional = nil
				}
				return .object(
					context.properties,
					required: context.required,
					additionalProperties: additional,
					xml: xml
				)
			case .boolean:
				return .primitive(.boolean, format: format)

			case .integer:
				return .primitive(.integer, format: format)

			case .number:
				return .primitive(.number, format: format)
			case let .string(context):
				return .primitive(.string, format: format, pattern: context.pattern)
			case let .composition(context):
				if let items = context.oneOf {
					return .composite(.oneOf, items, discriminator: context.discriminator)
				}
				if let items = context.allOf {
					return .composite(.allOf, items, discriminator: context.discriminator)
				}
				if let items = context.anyOf {
					return .composite(.anyOf, items, discriminator: context.discriminator)
				}
				if let item = context.not {
					return .composite(.not, [item], discriminator: context.discriminator)
				}
				return .any
			}
		}
		set {
			set(type: newValue)
		}
	}

	@available(*, deprecated, message: "Use contexts")
	private mutating func set(type: SchemaType) {
		context = SchemaContexts(type: type)
		switch type {
		case let .primitive(_, format, _):
			self.format = format
		case let .object(_, _, _, xml):
			self.xml = xml
		case let .enum(_, allCases):
			self.enum = allCases.map(AnyValue.string)
		default:
			break
		}
	}
}

private extension SchemaContexts {

	@available(*, deprecated)
	init?(type: SchemaType) {
		switch type {
		case .any:
			return nil
		case let .primitive(primitiveDataType, _, pattern):
			switch primitiveDataType {
			case .string:
				self = .string(StringContext(pattern: pattern))
			case .number:
				self = .number(NumberContext<Double>())
			case .integer:
				self = .integer(NumberContext<Int>())
			case .boolean:
				self = .boolean(BooleanContext())
			}
		case let .object(dictionary, required, additionalProperties, _):
			self = .object(
				ObjectContext(
					properties: dictionary.map {
						OrderedDictionary($0.sorted(by: { $0.key < $1.key })) { _, new in
							new
						}
					},
					additionalProperties: additionalProperties.map(AdditionalProperties.schema),
					required: required
				)
			)
		case let .array(items):
			self = .array(ArrayContext(items: items))
		case let .composite(compositeType, array, discriminator):
			switch compositeType {
			case .oneOf:
				self = .composition(.one(of: array, discriminator: discriminator))
			case .allOf:
				self = .composition(.all(of: array, discriminator: discriminator))
			case .anyOf:
				self = .composition(.any(of: array, discriminator: discriminator))
			case .not:
				self = .composition(.not(a: array.first ?? .any))
			}
		case let .enum(primitiveDataType, _):
			switch primitiveDataType {
			case .string:
				self = .string(StringContext())
			case .number:
				self = .number(NumberContext<Double>())
			case .integer:
				self = .integer(NumberContext<Int>())
			case .boolean:
				self = .boolean(BooleanContext())
			}
		}
	}
}

@available(*, deprecated, message: "Use SchemaContexts instead")
public indirect enum SchemaType: Equatable {

	case any

	case primitive(
		PrimitiveDataType,
		format: DataFormat? = nil,
		pattern: String? = nil
	)

	case object(
		OrderedDictionary<String, ReferenceOr<SchemaObject>>? = nil,
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

public extension ExpressibleBySchemaObject {

	@available(*, deprecated, message: "Use concrete type instead")
	static func primitive(
		_ type: PrimitiveDataType,
		format: DataFormat? = nil,
		pattern: String? = nil,
		description: String? = nil,
		nullable: Bool? = nil,
		example: AnyValue? = nil,
		externalDocs: ExternalDocumentationObject? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				.primitive(type, format: format, pattern: pattern),
				example: example,
				description: description,
				nullable: nullable,
				externalDocs: externalDocs
			)
		)
	}
}

public extension ExpressibleBySchemaObject {

	@available(*, deprecated, message: "Use init with(\\keyPath) instead")
	@_disfavoredOverload
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

	@available(*, deprecated, message: "Use init with(\\keyPath) instead")
	@_disfavoredOverload
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

	@available(*, deprecated, message: "Use init with(\\keyPath) instead")
	@_disfavoredOverload
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

	@available(*, deprecated, message: "Use init with(\\keyPath) instead")
	@_disfavoredOverload
	static func not(
		_ type: ReferenceOr<SchemaObject>,
		description: String? = nil,
		externalDocs: ExternalDocumentationObject? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				.composite(.not, [type], discriminator: nil),
				description: description,
				externalDocs: externalDocs
			)
		)
	}

	@available(*, deprecated, message: "Use init with(\\keyPath) instead")
	@_disfavoredOverload
	static func object(
		properties: OrderedDictionary<String, ReferenceOr<SchemaObject>>,
		required: Set<String> = [],
		xml: XMLObject? = nil,
		description: String? = nil,
		nullable: Bool? = nil,
		example: AnyValue? = nil,
		externalDocs: ExternalDocumentationObject? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				.object(properties.nilIfEmpty, required: required.nilIfEmpty, xml: xml),
				example: example,
				description: description,
				nullable: nullable,
				externalDocs: externalDocs
			)
		)
	}

	@available(*, deprecated, message: "Use init with(\\keyPath) instead")
	@_disfavoredOverload
	static func dictionary(
		of additionalProperties: ReferenceOr<SchemaObject>,
		xml: XMLObject? = nil,
		description: String? = nil,
		nullable: Bool? = nil,
		example: AnyValue? = nil,
		externalDocs: ExternalDocumentationObject? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				.object(additionalProperties: additionalProperties, xml: xml),
				example: example,
				description: description,
				nullable: nullable,
				externalDocs: externalDocs
			)
		)
	}

	@available(*, deprecated, message: "Use init with(\\keyPath) instead")
	@_disfavoredOverload
	static func array(
		of type: ReferenceOr<SchemaObject>,
		description: String? = nil,
		example: AnyValue? = nil,
		nullable: Bool? = nil,
		externalDocs: ExternalDocumentationObject? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				.array(type),
				example: example,
				description: description,
				nullable: nullable,
				externalDocs: externalDocs
			)
		)
	}

	@available(*, deprecated, message: "Use init with(\\keyPath) instead")
	@_disfavoredOverload
	static func `enum`(
		of type: PrimitiveDataType = .string,
		cases: [String],
		description: String? = nil,
		nullable: Bool? = nil,
		example: AnyValue? = nil,
		externalDocs: ExternalDocumentationObject? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				.enum(type, allCases: cases),
				example: example,
				description: description,
				nullable: nullable,
				externalDocs: externalDocs
			)
		)
	}

	@available(*, deprecated, message: "Use init with(\\keyPath) instead")
	@_disfavoredOverload
	static func string(
		format: DataFormat? = nil,
		description: String? = nil,
		nullable: Bool? = nil,
		example: String? = nil
	) -> Self {
		.primitive(.string, format: format, description: description, nullable: nullable, example: example.map { .string($0) })
	}

	@available(*, deprecated, message: "Use init with(\\keyPath) instead")
	@_disfavoredOverload
	static func number(
		format: DataFormat? = nil,
		description: String? = nil,
		nullable: Bool? = nil,
		example: Double? = nil
	) -> Self {
		.primitive(.number, format: format, description: description, nullable: nullable, example: example.map { .double($0) })
	}

	@available(*, deprecated, message: "Use init with(\\keyPath) instead")
	@_disfavoredOverload
	static func integer(
		format: DataFormat? = .int64,
		description: String? = nil,
		nullable: Bool? = nil,
		example: Int? = nil
	) -> Self {
		.primitive(.integer, format: format, description: description, nullable: nullable, example: example.map { .int($0) })
	}

	@available(*, deprecated, message: "Use init with(\\keyPath) instead")
	@_disfavoredOverload
	static func float(
		description: String? = nil,
		nullable: Bool? = nil,
		example: Float? = nil
	) -> Self {
		.number(format: .float, description: description, nullable: nullable, example: example.map { Double($0) })
	}

	@available(*, deprecated, message: "Use init with(\\keyPath) instead")
	@_disfavoredOverload
	static func decimal(
		description: String? = nil,
		nullable: Bool? = nil,
		example: Decimal? = nil
	) -> Self {
		.number(format: .decimal, description: description, nullable: nullable, example: (example as? NSDecimalNumber)?.doubleValue)
	}

	@available(*, deprecated, message: "Use init with(\\keyPath) instead")
	@_disfavoredOverload
	static func double(
		description: String? = nil,
		nullable: Bool? = nil,
		example: Double? = nil
	) -> Self {
		.number(format: .double, description: description, nullable: nullable, example: example)
	}

	@available(*, deprecated, message: "Use init with(\\keyPath) instead")
	@_disfavoredOverload
	static func boolean(
		description: String? = nil,
		nullable: Bool? = nil,
		example: Bool? = nil
	) -> Self {
		.primitive(.boolean, description: description, nullable: nullable, example: example.map { .bool($0) })
	}

	@available(*, deprecated, message: "Use init with(\\keyPath) instead")
	@_disfavoredOverload
	static func uri(
		description: String? = nil,
		nullable: Bool? = nil,
		example: String? = nil
	) -> Self {
		.string(format: .uri, description: description, nullable: nullable, example: example)
	}

	@available(*, deprecated, message: "Use init with(\\keyPath) instead")
	@_disfavoredOverload
	static func uuid(
		description: String? = nil,
		nullable: Bool? = nil,
		example: UUID? = nil
	) -> Self {
		.string(format: .uuid, description: description, nullable: nullable, example: example?.uuidString)
	}

	@available(*, deprecated, message: "Use init with(\\keyPath) instead")
	@_disfavoredOverload
	static func date(
		description: String? = nil,
		nullable: Bool? = nil,
		example: Date? = nil
	) -> Self {
		.string(format: .date, description: description, nullable: nullable, example: example.map { DateEncodingFormat.date($0) })
	}

	@available(*, deprecated, message: "Use init with(\\keyPath) instead")
	@_disfavoredOverload
	static func dateTime(
		description: String? = nil,
		nullable: Bool? = nil,
		example: Date? = nil
	) -> Self {
		.string(format: .dateTime, description: description, nullable: nullable, example: example.map { DateEncodingFormat.dateTime($0) })
	}
}
