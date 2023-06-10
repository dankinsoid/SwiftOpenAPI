import Foundation

public enum AdditionalProperties: Codable, Equatable, ExpressibleByBooleanLiteral, ExpressibleBySchemaObject, ExpressibleByReferenceOr {

	case boolean(Bool)
	case schema(ReferenceOr<SchemaObject>)

	public init(schemaObject: SchemaObject) {
		self = .schema(.value(schemaObject))
	}

	public init(referenceOr: ReferenceOr<SchemaObject>) {
		self = .schema(referenceOr)
	}

	public init(booleanLiteral value: Bool) {
		self = .boolean(value)
	}

	public init(from decoder: Decoder) throws {
		do {
			self = try .boolean(Bool(from: decoder))
		} catch {
			self = try .schema(ReferenceOr<SchemaObject>(from: decoder))
		}
	}

	public func encode(to encoder: Encoder) throws {
		switch self {
		case let .boolean(value):
			try value.encode(to: encoder)
		case let .schema(schema):
			try schema.encode(to: encoder)
		}
	}

	public var asSchemaObject: SchemaObject? {
		get {
			switch self {
			case let .schema(object): return object.object
			default: return nil
			}
		}
		set {
			if let newValue {
				self = .schema(.value(newValue))
			}
		}
	}
}
