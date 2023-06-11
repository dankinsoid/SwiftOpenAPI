import Foundation

public enum ReferenceOr<Object> {

	case value(Object)
	case ref(ReferenceObject)

	public var ref: ReferenceObject? {
		get {
			if case let .ref(referenceObject) = self {
				return referenceObject
			}
			return nil
		}
		set {
			if let newValue {
				self = .ref(newValue)
			}
		}
	}

	public var object: Object? {
		get {
			if case let .value(value) = self {
				return value
			}
			return nil
		}
		set {
			if let newValue {
				self = .value(newValue)
			}
		}
	}
}

extension ReferenceOr: Equatable where Object: Equatable {}

extension ReferenceOr: Encodable where Object: Encodable {

	public func encode(to encoder: Encoder) throws {
		switch self {
		case let .value(object):
			try object.encode(to: encoder)
		case let .ref(referenceObject):
			try referenceObject.encode(to: encoder)
		}
	}
}

extension ReferenceOr: Decodable where Object: Decodable {

	public init(from decoder: Decoder) throws {
		do {
			self = try .ref(ReferenceObject(from: decoder))
		} catch {
			self = try .value(Object(from: decoder))
		}
	}
}

extension ReferenceOr: ExpressibleByUnicodeScalarLiteral where Object: ExpressibleByUnicodeScalarLiteral {

	public init(unicodeScalarLiteral value: Object.UnicodeScalarLiteralType) {
		self = .value(Object(unicodeScalarLiteral: value))
	}
}

extension ReferenceOr: ExpressibleByExtendedGraphemeClusterLiteral where Object: ExpressibleByExtendedGraphemeClusterLiteral {

	public init(extendedGraphemeClusterLiteral value: Object.ExtendedGraphemeClusterLiteralType) {
		self = .value(Object(extendedGraphemeClusterLiteral: value))
	}
}

extension ReferenceOr: ExpressibleByStringLiteral where Object: ExpressibleByStringLiteral {

	public init(stringLiteral value: Object.StringLiteralType) {
		self = .value(Object(stringLiteral: value))
	}
}

extension ReferenceOr: ExpressibleByFloatLiteral where Object: ExpressibleByFloatLiteral {

	public init(floatLiteral value: Object.FloatLiteralType) {
		self = .value(Object(floatLiteral: value))
	}
}

extension ReferenceOr: ExpressibleByIntegerLiteral where Object: ExpressibleByIntegerLiteral {

	public init(integerLiteral value: Object.IntegerLiteralType) {
		self = .value(Object(integerLiteral: value))
	}
}

extension ReferenceOr: ExpressibleByBooleanLiteral where Object: ExpressibleByBooleanLiteral {

	public init(booleanLiteral value: Object.BooleanLiteralType) {
		self = .value(Object(booleanLiteral: value))
	}
}

extension ReferenceOr: ExpressibleByStringInterpolation where Object: ExpressibleByStringInterpolation {

	public init(stringInterpolation value: Object.StringInterpolation) {
		self = .value(Object(stringInterpolation: value))
	}
}

extension ReferenceOr: ExpressibleByArrayLiteral where Object: ExpressibleByArray {

	public init(arrayLiteral elements: Object.ArrayLiteralElement...) {
		self = .value(Object(arrayElements: elements))
	}
}

extension ReferenceOr: ExpressibleByArray where Object: ExpressibleByArray {

	public init(arrayElements elements: [Object.ArrayLiteralElement]) {
		self = .value(Object(arrayElements: elements))
	}
}

extension ReferenceOr: ExpressibleByDictionaryLiteral where Object: ExpressibleByDictionary {

	public init(dictionaryLiteral elements: (Object.Key, Object.Value)...) {
		self = .value(Object(dictionaryElements: elements))
	}
}

extension ReferenceOr: MutableDictionary where Object: MutableDictionary {

	public typealias Key = Object.Key
	public typealias Value = Object.Value

	public subscript(key: Object.Key) -> Object.Value? {
		get {
			if case let .value(object) = self {
				return object[key]
			}
			return nil
		}
		set {
			if case var .value(object) = self {
				object[key] = newValue
				self = .value(object)
			}
		}
	}
}

extension ReferenceOr: ExpressibleByDictionary where Object: ExpressibleByDictionary {

	public init(dictionaryElements elements: [(Object.Key, Object.Value)]) {
		self = .value(Object(dictionaryElements: elements))
	}
}

public protocol ExpressibleByReferenceOr<Object>: ReferenceObjectExpressible {

	associatedtype Object

	init(referenceOr: ReferenceOr<Object>)
}

public extension ReferenceObjectExpressible where Self: ExpressibleByReferenceOr {

	init(referenceObject: ReferenceObject) {
		self.init(referenceOr: .ref(referenceObject))
	}
}

extension ReferenceOr: ExpressibleByReferenceOr {

	public init(referenceOr: ReferenceOr<Object>) {
		self = referenceOr
	}
}

public extension ExpressibleByReferenceOr {

	static func ref(components keyPath: WritableKeyPath<ComponentsObject, ComponentsMap<Object>?>, _ name: String) -> Self {
		let path: String
		if let name = names[keyPath] {
			path = name
		} else {
			var object = ComponentsObject()
			object[keyPath: keyPath] = [:]
			let anyValue = try? AnyValue.encode(object)
			switch anyValue {
			case let .object(dictionary):
				path = dictionary.keys.first ?? "schemas"
			default:
				path = "schemas"
			}
			names[keyPath] = path
		}
		return .ref(components: path, name)
	}

	static func ref(components keyPath: WritableKeyPath<ComponentsObject, ComponentsMap<Object>?>, _ type: Any.Type) -> Self {
		.ref(components: keyPath, .typeName(type))
	}
}

public extension ExpressibleByReferenceOr<SchemaObject> {

	static func ref(schema: Encodable, dateFormat: DateEncodingFormat = .default, into schemas: inout ComponentsMap<SchemaObject>) -> Self {
		_ = try? encodeSchema(schema, dateFormat: dateFormat, into: &schemas)
		return .ref(components: \.schemas, .typeName(type(of: schema)))
	}

	static func encodeSchema(
		_ value: Encodable,
		dateFormat: DateEncodingFormat = .default,
		keyEncodingStrategy: KeyEncodingStrategy = .default,
		into schemas: inout ComponentsMap<SchemaObject>
	) throws -> Self {
		let encoder = SchemeEncoder(dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
		return try Self(referenceOr: encoder.encode(value, into: &schemas))
	}

	static func decodeSchema(
		_ type: Decodable.Type,
		dateFormat: DateEncodingFormat = .default,
		keyEncodingStrategy: KeyEncodingStrategy = .default,
		into schemas: inout ComponentsMap<SchemaObject>
	) throws -> Self {
		let decoder = SchemeEncoder(dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
		return try Self(referenceOr: decoder.decode(type, into: &schemas))
	}
}

public extension ExpressibleByReferenceOr<ExampleObject> {

	static func ref(example value: Encodable, dateFormat: DateEncodingFormat = .default, into examples: inout ComponentsMap<ExampleObject>) throws -> Self {
		let encoder = AnyValueEncoder(dateFormat: dateFormat)
		let example = try encoder.encode(value)
		let typeName = String.typeName(type(of: value))
		var name = typeName
		var i = 0
		while let current = examples[name]?.object?.value, current != example {
			i += 1
			name = "\(typeName)\(i)"
		}
		examples[name] = .value(ExampleObject(value: example))
		return .ref(components: \.examples, name)
	}
}

private var names: [PartialKeyPath<ComponentsObject>: String] = [
	\.schemas: "schemas",
	\.parameters: "parameters",
	\.responses: "responses",
	\.requestBodies: "requestBodies",
	\.pathItems: "pathItems",
	\.examples: "examples",
	\.headers: "headers",
	\.links: "links",
	\.callbacks: "callbacks",
	\.securitySchemes: "securitySchemes",
]
