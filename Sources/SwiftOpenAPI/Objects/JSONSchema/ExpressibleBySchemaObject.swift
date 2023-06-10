import Foundation

public protocol ExpressibleBySchemaObject {

	init(schemaObject: SchemaObject)
	var asSchemaObject: SchemaObject? { get set }
}

extension SchemaObject: ExpressibleBySchemaObject {

	public init(schemaObject: SchemaObject) {
		self = schemaObject
	}

	public var asSchemaObject: SchemaObject? {
		get { self }
		set {
			if let newValue {
				self = newValue
			}
		}
	}
}

extension ReferenceOr<SchemaObject>: ExpressibleBySchemaObject {

	public init(schemaObject: SchemaObject) {
		self = .value(schemaObject)
	}

	public var asSchemaObject: SchemaObject? {
		get { object }
		set { object = newValue }
	}
}

public extension ExpressibleBySchemaObject {

	func with<T>(_ keyPath: WritableKeyPath<SchemaObject, T>, _ value: T) -> Self {
		var result = self
		result.asSchemaObject?[keyPath: keyPath] = value
		return result
	}

	static func one(
		of types: ReferenceOr<SchemaObject>...,
		discriminator: DiscriminatorObject? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				context: .composition(.one(of: types, discriminator: discriminator))
			)
		)
	}

	static func all(
		of types: ReferenceOr<SchemaObject>...,
		discriminator: DiscriminatorObject? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				context: .composition(.all(of: types, discriminator: discriminator))
			)
		)
	}

	static func any(
		of types: ReferenceOr<SchemaObject>...,
		discriminator: DiscriminatorObject? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				context: .composition(.any(of: types, discriminator: discriminator))
			)
		)
	}

	static func not(
		a type: ReferenceOr<SchemaObject>
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				context: .composition(.not(a: type))
			)
		)
	}

	static var any: Self {
		Self(schemaObject: SchemaObject())
	}

	static func object(
		properties: OrderedDictionary<String, ReferenceOr<SchemaObject>>,
		required: Set<String> = [],
		size: AnyRange<Int> = .any
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				context: .object(
					ObjectContext(
						properties: properties,
						required: required,
						size: size
					)
				)
			)
		)
	}

	static func dictionary(
		of additionalProperties: ReferenceOr<SchemaObject>,
		minProperties: Int? = nil,
		maxProperties: Int? = nil,
		size: AnyRange<Int> = .any
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				context: .object(
					ObjectContext(
						properties: nil,
						additionalProperties: .schema(additionalProperties),
						size: size
					)
				)
			)
		)
	}

	static func array(
		of type: ReferenceOr<SchemaObject>,
		size: AnyRange<Int> = .any,
		uniqueItems: Bool? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				context: .array(
					ArrayContext(
						items: type,
						size: size,
						uniqueItems: uniqueItems
					)
				)
			)
		)
	}

	static func `enum`(
		of type: PrimitiveDataType = .string,
		cases: [AnyValue]
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				enum: cases,
				context: SchemaContexts(type)
			)
		)
	}

	static func `enum`<T>(
		_ type: T.Type,
		example: T? = nil
	) -> Self where T: CaseIterable, T.AllCases.Element: RawRepresentable, T.AllCases.Element.RawValue == String {
		.enum(cases: type.allCases.map { .string($0.rawValue) })
			.with(\.example, example.map { .string($0.rawValue) })
	}

	static var string: Self {
		.string()
	}

	static func string(
		format: DataFormat? = nil,
		pattern: String? = nil,
		size: AnyRange<Int> = .any,
		example: String? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				format: format,
				example: example.map { .string($0) },
				context: .string(
					StringContext(
						pattern: pattern,
						size: size
					)
				)
			)
		)
	}

	static func number(
		format: DataFormat? = nil,
		range: AnyRange<Double> = .any,
		multipleOf: Double? = nil,
		example: Double? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				format: format,
				example: example.map { .double($0) },
				context: .number(
					NumberContext(
						range: range,
						multipleOf: multipleOf
					)
				)
			)
		)
	}

	static var number: Self { .number() }

	static func integer(
		format: DataFormat? = .int64,
		range: AnyRange<Int> = .any,
		multipleOf: Int? = nil,
		example: Int? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				format: format,
				example: example.map { .int($0) },
				context: .integer(
					NumberContext(
						range: range,
						multipleOf: multipleOf
					)
				)
			)
		)
	}

	static var integer: Self { .integer(format: .int64) }

	static func float(
		range: AnyRange<Float> = .any,
		multipleOf: Float? = nil,
		example: Float? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				format: .float,
				example: example.map { .double(Double($0)) },
				context: .number(
					NumberContext(
						range: AnyRange(
							lowerBound: range.lowerBound.map { Double($0) },
							upperBound: range.upperBound.map { Double($0) },
							include: range.include
						),
						multipleOf: multipleOf.map { Double($0) }
					)
				)
			)
		)
	}

	static var float: Self { .float() }

	static func decimal(
		format: DataFormat? = .decimal,
		range: AnyRange<Decimal> = .any,
		multipleOf: Decimal? = nil,
		example: Decimal? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				format: format,
				example: example.map { .double($0.double) },
				context: .number(
					NumberContext(
						range: AnyRange(
							lowerBound: range.lowerBound.map(\.double),
							upperBound: range.upperBound.map(\.double),
							include: range.include
						),
						multipleOf: multipleOf.map(\.double)
					)
				)
			)
		)
	}

	static var decimal: Self { .decimal() }

	static func double(
		range: AnyRange<Double> = .any,
		multipleOf: Double? = nil,
		example: Double? = nil
	) -> Self {
		.number(
			format: .double,
			range: range,
			multipleOf: multipleOf,
			example: example
		)
	}

	static var double: Self { .double() }

	static func boolean(
		example: Bool? = nil
	) -> Self {
		Self(
			schemaObject: SchemaObject(
				example: example.map { .bool($0) },
				context: .boolean
			)
		)
	}

	static var boolean: Self { .boolean() }

	static func uuid(
		example: UUID? = nil
	) -> Self {
		.string(format: .uuid, example: example?.uuidString)
	}

	static var uuid: Self { .uuid() }

	static func uri(
		example: UUID? = nil
	) -> Self {
		.string(format: .uri, example: example?.uuidString)
	}

	static var uri: Self { .uri() }

	static func date(
		example: Date? = nil
	) -> Self {
		.string(format: .date, example: example.map { DateEncodingFormat.date($0) })
	}

	static var date: Self { .date() }

	static func dateTime(
		example: Date? = nil
	) -> Self {
		.string(format: .date, example: example.map { DateEncodingFormat.dateTime($0) })
	}

	static var dateTime: Self { .dateTime() }
}
