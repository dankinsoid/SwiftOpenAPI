import Foundation

/// While the OpenAPI Specification tries to accommodate most use cases, additional data can be added to extend the specification at certain points.
///
/// The extensions properties are implemented as patterned fields that are always prefixed by "x-".
public protocol SpecificationExtendable {

	var specificationExtensions: SpecificationExtensions? { get set }
}

public struct SpecificationExtensions: Codable, ExpressibleByDictionary, Equatable {

	public typealias Value = AnyValue

	public var fields: [Key: AnyValue]

	public subscript(_ key: Key) -> AnyValue? {
		get { fields[key] }
		set { fields[key] = newValue }
	}

	public init(dictionaryElements elements: [(Key, AnyValue)]) {
		fields = Dictionary(elements) { _, s in s }
	}

	public init(from decoder: Decoder) throws {
		fields = [:]
		let container = try decoder.container(keyedBy: StringKey<Key>.self)
		for key in container.allKeys {
			fields[key.value] = try container.decodeIfPresent(AnyValue.self, forKey: key)
		}
	}
	
	public init(
		from value: some Encodable,
		encoder: JSONEncoder = JSONEncoder(),
		decoder: JSONDecoder = JSONDecoder()
	) throws {
		encoder.keyEncodingStrategy = .specificationExtension
		decoder.keyDecodingStrategy = .useDefaultKeys
		let data = try encoder.encode(value)
		self = try decoder.decode(SpecificationExtensions.self, from: data)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: StringKey<Key>.self)
		for (key, value) in fields {
			try container.encode(value, forKey: StringKey(key))
		}
	}

	public struct Key: LosslessStringConvertible, Codable, ExpressibleByStringLiteral, Hashable {

		public let name: String
		public var description: String { name }

		public init?(_ description: String) {
			guard description.hasPrefix("x-") else {
				return nil
			}
			name = description
		}

		public init(stringLiteral value: String) {
			if let result = Self(value) {
				self = result
			} else {
				name = "x-\(value)"
			}
		}

		public init(from decoder: Decoder) throws {
			try self.init(stringLiteral: String(from: decoder))
		}

		public func encode(to encoder: Encoder) throws {
			try description.encode(to: encoder)
		}
	}
}

@propertyWrapper
public struct WithSpecExtensions<Wrapped: SpecificationExtendable> {
	
	public var wrappedValue: Wrapped
	public var projectedValue: SpecificationExtensions {
		get { wrappedValue.specificationExtensions ?? [:] }
		set { wrappedValue.specificationExtensions = newValue }
	}
	
	public init(wrappedValue: Wrapped) {
		self.wrappedValue = wrappedValue
	}
}

extension WithSpecExtensions {
	
	public init<T>() where T? == Wrapped {
		self.init(wrappedValue: nil)
	}
}

extension WithSpecExtensions: Decodable where Wrapped: Decodable {
	
	public init(from decoder: Decoder) throws {
		var wrapped = try Wrapped(from: decoder)
		wrapped.specificationExtensions = try? SpecificationExtensions(from: decoder)
		self.init(wrappedValue: wrapped)
	}
}

extension WithSpecExtensions: Encodable where Wrapped: Encodable {
	
	public func encode(to encoder: Encoder) throws {
		try projectedValue.encode(to: encoder)
		var wrapped = wrappedValue
		wrapped.specificationExtensions = nil
		try wrapped.encode(to: encoder)
	}
}

extension WithSpecExtensions: Equatable where Wrapped: Equatable {
}

extension Optional: SpecificationExtendable where Wrapped: SpecificationExtendable {
	
	public var specificationExtensions: SpecificationExtensions? {
		get { self?.specificationExtensions }
		set { self?.specificationExtensions = newValue }
	}
}

extension JSONDecoder.KeyDecodingStrategy {
	
	public static var specificationExtension: JSONDecoder.KeyDecodingStrategy {
		.custom { codingPath in
			guard let last = codingPath.last else {
				return StringKey<String>("")
			}
		
			let string = last.stringValue.replacingOccurrences(of: "_", with: "-").toCamelCase(separator: "-")
			return StringKey(SpecificationExtensions.Key(stringLiteral: string))
		}
	}
}

extension JSONEncoder.KeyEncodingStrategy {
	
	public static var specificationExtension: JSONEncoder.KeyEncodingStrategy {
		.custom { codingPath in
			guard let last = codingPath.last else {
				return StringKey<String>("")
			}
			
			let string = last.stringValue.toSnakeCase(separator: "-").replacingOccurrences(of: "_", with: "-")
			return StringKey(SpecificationExtensions.Key(stringLiteral: string))
		}
	}
}

extension KeyedDecodingContainer {

	public func decodeIfPresent<T: SpecificationExtendable & Decodable>(_ type: T.Type, forKey key: Key) throws -> T? {
		try decodeIfPresent(WithSpecExtensions<T>.self, forKey: key)?.wrappedValue
	}

	public func decode<T: SpecificationExtendable & Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
		try decode(WithSpecExtensions<T>.self, forKey: key).wrappedValue
	}
}

extension UnkeyedDecodingContainer {
	
	public mutating func decode<T: SpecificationExtendable & Decodable>(_ type: T.Type) throws -> T {
		try decode(WithSpecExtensions<T>.self).wrappedValue
	}
	
	public mutating func decodeIfPresent<T: SpecificationExtendable & Decodable>(_ type: T.Type) throws -> T? {
		try decodeIfPresent(WithSpecExtensions<T>.self)?.wrappedValue
	}
}

extension KeyedEncodingContainer {

	public mutating func encodeIfPresent(_ value: (some SpecificationExtendable & Encodable)?, forKey key: K) throws {
		try encodeIfPresent(value.map { WithSpecExtensions(wrappedValue: $0) }, forKey: key)
	}

	public mutating func encode(_ value: some SpecificationExtendable & Encodable, forKey key: K) throws {
		try encode(WithSpecExtensions(wrappedValue: value), forKey: key)
	}
}

extension UnkeyedEncodingContainer {
	
	public mutating func encode<T: SpecificationExtendable & Encodable>(_ value: T) throws {
		try encode(WithSpecExtensions(wrappedValue: value))
	}
	
	public mutating func encode<T>(contentsOf sequence: T) throws where T : Sequence, T.Element: Encodable, T.Element: SpecificationExtendable {
		try encode(contentsOf: sequence.map { WithSpecExtensions(wrappedValue: $0) })
	}
}

extension SingleValueEncodingContainer {
	
	public mutating func encode<T: Encodable & SpecificationExtendable>(_ value: T) throws {
		try encode(WithSpecExtensions(wrappedValue: value))
	}
}

extension SingleValueDecodingContainer {
	
	public func decode<T: Decodable & SpecificationExtendable>(_ type: T.Type) throws -> T {
		try decode(WithSpecExtensions<T>.self).wrappedValue
	}
}

public extension SpecificationExtendable where Self: Encodable {
	
	func json(encoder: JSONEncoder = JSONEncoder()) throws -> Data {
		encoder.outputFormatting.insert(.sortedKeys)
		return try encoder.encode(WithSpecExtensions(wrappedValue: self))
	}
}

public extension SpecificationExtendable where Self: Decodable {
	
	init(json: Data, decoder: JSONDecoder = JSONDecoder()) throws {
		self = try decoder.decode(WithSpecExtensions<Self>.self, from: json).wrappedValue
	}
}
