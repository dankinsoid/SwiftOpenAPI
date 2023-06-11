import Foundation

public indirect enum SchemaContexts: Equatable {

	case object(ObjectContext)
	case array(ArrayContext)
	case integer(NumberContext<Int>)
	case number(NumberContext<Double>)
	case string(StringContext)
	case boolean(BooleanContext)
	case composition(CompositionContext)

	public var type: DataType? {
		switch self {
		case .object: return .object
		case .array: return .array
		case .integer: return .integer
		case .number: return .number
		case .string: return .string
		case .boolean: return .boolean
		case .composition: return nil
		}
	}

	public static var integer: SchemaContexts {
		.integer(NumberContext<Int>())
	}

	public static var number: SchemaContexts {
		.number(NumberContext<Double>())
	}

	public static var string: SchemaContexts {
		.string(StringContext())
	}

	public static var boolean: SchemaContexts {
		.boolean(BooleanContext())
	}

	public init(_ type: PrimitiveDataType) {
		switch type {
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

public struct ArrayContext: Codable, Equatable {

	public var items: ReferenceOr<SchemaObject>
	private var minItems: Int?
	private var maxItems: Int?
	public var uniqueItems: Bool?

	public var size: AnyRange<Int> {
		get {
			AnyRange(
				lowerBound: minItems,
				upperBound: maxItems,
				include: [.lower, .upper]
			)
		}
		set {
			(minItems, maxItems) = ObjectContext.values(from: newValue)
		}
	}

	public init(
		items: ReferenceOr<SchemaObject>,
		size: AnyRange<Int> = .any,
		uniqueItems: Bool? = nil
	) {
		self.items = items
		(minItems, maxItems) = ObjectContext.values(from: size)
		self.uniqueItems = uniqueItems
	}
}

public struct BooleanContext: Codable, Equatable {

	public init() {}
}

public struct NumberContext<Number: Codable & Comparable>: Codable, Equatable {

	private var minimum: Number?
	private var maximum: Number?
	private var exclusiveMinimum: Number?
	private var exclusiveMaximum: Number?
	public var multipleOf: Number?

	public var range: AnyRange<Number> {
		get {
			AnyRange(
				lowerBound: minimum ?? exclusiveMaximum,
				upperBound: maximum ?? exclusiveMaximum,
				include: {
					var result: Set<RangeEdge> = []
					if minimum != nil { result.insert(.lower) }
					if maximum != nil { result.insert(.upper) }
					return result
				}()
			)
		}
		set {
			(minimum, maximum, exclusiveMinimum, exclusiveMaximum) = Self.values(from: newValue)
		}
	}

	public init(
		range: AnyRange<Number> = .any,
		multipleOf: Number? = nil
	) {
		self.multipleOf = multipleOf
		(minimum, maximum, exclusiveMinimum, exclusiveMaximum) = Self.values(from: range)
	}

	private static func values(from range: AnyRange<Number>) -> (
		minimum: Number?,
		maximum: Number?,
		exclusiveMinimum: Number?,
		exclusiveMaximum: Number?
	) {
		(
			range.include.contains(.lower) ? range.lowerBound : nil,
			range.include.contains(.upper) ? range.upperBound : nil,
			!range.include.contains(.lower) ? range.lowerBound : nil,
			!range.include.contains(.upper) ? range.upperBound : nil
		)
	}
}

public struct ObjectContext: Codable, Equatable {

	public var properties: ComponentsMap<SchemaObject>?
	public var additionalProperties: AdditionalProperties?
	public var required: Set<String>?
	private var minProperties: Int?
	private var maxProperties: Int?

	public var size: AnyRange<Int> {
		get {
			AnyRange(
				lowerBound: minProperties,
				upperBound: maxProperties,
				include: [.lower, .upper]
			)
		}
		set {
			(minProperties, maxProperties) = Self.values(from: newValue)
		}
	}

	public init(
		properties: ComponentsMap<SchemaObject>? = nil,
		additionalProperties: AdditionalProperties? = nil,
		required: Set<String>? = nil,
		size: AnyRange<Int> = .any
	) {
		self.properties = properties?.nilIfEmpty
		self.additionalProperties = additionalProperties
		self.required = required?.nilIfEmpty
		(minProperties, maxProperties) = Self.values(from: size)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(properties?.nilIfEmpty, forKey: .properties)
		try container.encodeIfPresent(additionalProperties, forKey: .additionalProperties)
		try container.encodeIfPresent(required?.nilIfEmpty?.sorted(), forKey: .required)
		try container.encodeIfPresent(minProperties, forKey: .minProperties)
		try container.encodeIfPresent(maxProperties, forKey: .maxProperties)
	}

	static func values(from range: AnyRange<Int>) -> (
		minimum: Int?,
		maximum: Int?
	) {
		(
			range.lowerBound.map { range.include.contains(.lower) ? $0 : $0 + 1 },
			range.upperBound.map { range.include.contains(.upper) ? $0 : $0 - 1 }
		)
	}
}

public struct StringContext: Codable, Equatable {

	public var pattern: String?
	private var minLength: Int?
	private var maxLength: Int?

	public var size: AnyRange<Int> {
		get {
			AnyRange(
				lowerBound: minLength,
				upperBound: maxLength,
				include: [.lower, .upper]
			)
		}
		set {
			(minLength, maxLength) = ObjectContext.values(from: newValue)
		}
	}

	public init(
		pattern: String? = nil,
		size: AnyRange<Int> = .any
	) {
		self.pattern = pattern
		(minLength, maxLength) = ObjectContext.values(from: size)
	}
}

public struct CompositionContext: Codable, Equatable {

	public var allOf: [ReferenceOr<SchemaObject>]?
	public var oneOf: [ReferenceOr<SchemaObject>]?
	public var anyOf: [ReferenceOr<SchemaObject>]?
	public var not: ReferenceOr<SchemaObject>?
	public var discriminator: DiscriminatorObject?

	public static func all(of schemas: [ReferenceOr<SchemaObject>], discriminator: DiscriminatorObject? = nil) -> CompositionContext {
		CompositionContext(allOf: schemas, discriminator: discriminator)
	}

	public static func one(of schemas: [ReferenceOr<SchemaObject>], discriminator: DiscriminatorObject? = nil) -> CompositionContext {
		CompositionContext(oneOf: schemas, discriminator: discriminator)
	}

	public static func any(of schemas: [ReferenceOr<SchemaObject>], discriminator: DiscriminatorObject? = nil) -> CompositionContext {
		CompositionContext(anyOf: schemas, discriminator: discriminator)
	}

	public static func not(a schema: ReferenceOr<SchemaObject>) -> CompositionContext {
		CompositionContext(not: schema)
	}

	static let invalid = CompositionContext()
}
