import Foundation

/// While the OpenAPI Specification tries to accommodate most use cases, additional data can be added to extend the specification at certain points.
///
/// The extensions properties are implemented as patterned fields that are always prefixed by "x-".
public protocol SpecificationExtendable {

//	var specificationExtensions: SpecificationExtensions? { get set }
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

extension Decoder {

	func decodeDictionary<Key: LosslessStringConvertible, Value: Decodable>(of type: [Key: Value].Type) throws -> [Key: Value] {
		let container = try container(keyedBy: StringKey<Key>.self)
		let pairs = try container.allKeys.compactMap {
			try ($0.value, container.decode(Value.self, forKey: $0))
		}
		return Dictionary(pairs) { _, second in
				second
		}
	}
}
//
//extension KeyedDecodingContainer {
//
//	public func decodeIfPresent<T: SpecificationExtendable & Decodable>(_ type: T.Type, forKey key: Key) throws -> T? {
//		guard var value = try _decodeIfPresent(type, forKey: key) else {
//			return nil
//		}
//		let extensions = try _decode(SpecificationExtensions.self, forKey: key)
//		value.specificationExtensions = extensions
//		return value
//	}
//
//	private func _decodeIfPresent<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T? {
//		try decodeIfPresent(type, forKey: key)
//	}
//
//	public func decode<T: SpecificationExtendable & Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
//		var value = try _decode(type, forKey: key)
//		let extensions = try decode(SpecificationExtensions.self, forKey: key)
//		value.specificationExtensions = extensions
//		return value
//	}
//
//	private func _decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
//		try decode(type, forKey: key)
//	}
//}
//
extension Encoder {

	func encodeDictionary<Key: LosslessStringConvertible>(_ dict: [Key: some Encodable]) throws {
		var container = container(keyedBy: StringKey<Key>.self)
		for (key, value) in dict {
			try container.encode(value, forKey: StringKey(key))
		}
	}
}
//
//extension KeyedEncodingContainer {
//
//	public mutating func encodeIfPresent(_ value: (some SpecificationExtendable & Encodable)?, forKey key: K) throws {
//		try _encodeIfPresent(value, forKey: key)
//		try encodeIfPresent(value?.specificationExtensions, forKey: key)
//	}
//
//	private mutating func _encodeIfPresent(_ value: (some Encodable)?, forKey key: K) throws {
//		try encodeIfPresent(value, forKey: key)
//	}
//
//	public mutating func encode(_ value: some SpecificationExtendable & Encodable, forKey key: K) throws {
//		try _encode(value, forKey: key)
//		try encode(value.specificationExtensions, forKey: key)
//	}
//
//	private mutating func _encode(_ value: some Encodable, forKey key: K) throws {
//		try encode(value, forKey: key)
//	}
//}
