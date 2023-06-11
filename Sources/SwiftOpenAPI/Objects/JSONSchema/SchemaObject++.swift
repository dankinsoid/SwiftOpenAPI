import Foundation

extension SchemaObject: ExpressibleByDictionary {

	public typealias Key = String
	public typealias Value = ReferenceOr<SchemaObject>

	public init(dictionaryElements elements: [(String, ReferenceOr<SchemaObject>)]) {
		self = .object(
			properties: OrderedDictionary(elements) { _, s in s }
		)
	}

	public subscript(key: String) -> ReferenceOr<SchemaObject>? {
		get {
			if case let .object(context) = context {
				return context.properties?[key]
			}
			return nil
		}
		set {
			if case var .object(objectContext) = context {
				objectContext.properties?[key] = newValue
				context = .object(objectContext)
			}
		}
	}
}

extension SchemaObject {

	var isReferenceable: Bool {
		switch context {
		case .none, .array, .string, .number, .integer, .boolean:
			return self.enum?.isEmpty == false
		case .composition:
			return true
		case let .object(context):
			switch context.additionalProperties {
			case .schema:
				return false
			case let .boolean(value):
				return !value
			case .none:
				return true
			}
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
		keyEncodingStrategy: KeyEncodingStrategy = .default,
		into schemas: inout ComponentsMap<SchemaObject>
	) throws {
		let encoder = SchemeEncoder(dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
		try encoder.encode(value, into: &schemas)
	}

	static func decode(
		_ type: Decodable.Type,
		dateFormat: DateEncodingFormat = .default,
		keyEncodingStrategy: KeyEncodingStrategy = .default,
		into schemas: inout ComponentsMap<SchemaObject>
	) throws {
		let encoder = SchemeEncoder(dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
		try encoder.decode(type, into: &schemas)
	}
}
