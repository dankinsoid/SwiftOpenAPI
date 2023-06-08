import Foundation
import OpenAPIKit

extension AnyCodable {
	
	public static func encode(
		_ value: Encodable,
		dateFormat: DateEncodingFormat = .default,
		keyEncodingStrategy: KeyEncodingStrategy = .default
	) throws -> AnyCodable {
		let encoder = AnyValueEncoder(dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
		return try encoder.encode(value)
	}
}

final class AnyValueEncoder: Encoder {

	var codingPath: [CodingKey]
	var userInfo: [CodingUserInfoKey: Any]
	var result: AnyCodable
	var dateFormat: DateEncodingFormat
	var keyEncodingStrategy: KeyEncodingStrategy

	init(
		codingPath: [CodingKey] = [],
		dateFormat: DateEncodingFormat,
		keyEncodingStrategy: KeyEncodingStrategy
	) {
		self.codingPath = codingPath
		userInfo = [:]
		self.dateFormat = dateFormat
		self.keyEncodingStrategy = keyEncodingStrategy
		result = AnyCodable(())
	}

	func container<Key>(keyedBy _: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
		let container = AnyValueKeyedEncodingContainer<Key>(
			codingPath: codingPath,
			dateFormat: dateFormat,
			keyEncodingStrategy: keyEncodingStrategy,
			result: Ref { [self] in
				guard let value = result.value as? [String: Any?] else { return [:] }
				return value
			} set: { [self] newValue in
				result = AnyCodable(newValue)
			}
		)
		return KeyedEncodingContainer(container)
	}

	func unkeyedContainer() -> UnkeyedEncodingContainer {
		AnyValueUnkeyedEncodingContainer(
			codingPath: codingPath,
			dateFormat: dateFormat,
			keyEncodingStrategy: keyEncodingStrategy,
			result: Ref { [self] in
				if let value = result.value as? [Any?] {
					return value
				}
				return []
			} set: { [self] newValue in
				result = AnyCodable(newValue)
			}
		)
	}

	func singleValueContainer() -> SingleValueEncodingContainer {
		AnyValueSingleValueEncodingContainer(
			codingPath: codingPath,
			dateFormat: dateFormat,
			keyEncodingStrategy: keyEncodingStrategy,
			result: Ref { [self] in
				result.value
			} set: { [self] newValue in
				result = AnyCodable(newValue)
			}
		)
	}

	func encode(_ value: Encodable) throws -> AnyCodable {
		switch value {
		case let date as Date:
			var container = singleValueContainer()
			try dateFormat.encode(date, &container)

		case let date as Date?:
			if let date {
				var container = singleValueContainer()
				try dateFormat.encode(date, &container)
			}

		case let data as Data:
			try data.base64EncodedString().encode(to: self)

		case let data as Data?:
			try data?.base64EncodedString().encode(to: self)

		case let url as URL:
			try url.absoluteString.encode(to: self)

		case let url as URL?:
			try url?.absoluteString.encode(to: self)

		case let decimal as Decimal:
			try decimal.description.encode(to: self)

		case let decimal as Decimal?:
			try decimal?.description.encode(to: self)

		default:
			try value.encode(to: self)
		}
		return result
	}
}

private struct AnyValueSingleValueEncodingContainer: SingleValueEncodingContainer {

	var codingPath: [CodingKey]
	let dateFormat: DateEncodingFormat
	let keyEncodingStrategy: KeyEncodingStrategy
	@Ref var result: Any?

	mutating func encodeNil() throws {}

	mutating func encode(_ value: Bool) throws {
		result = value
	}

	mutating func encode(_ value: String) throws {
		result = value
	}

	mutating func encode(_ value: Double) throws {
		result = value
	}

	mutating func encode(_ value: Float) throws {
		result = value
	}

	mutating func encode(_ value: Int) throws {
		result = value
	}

	mutating func encode(_ value: Int8) throws {
		result = value
	}

	mutating func encode(_ value: Int16) throws {
		result = value
	}

	mutating func encode(_ value: Int32) throws {
		result = value
	}

	mutating func encode(_ value: Int64) throws {
		result = value
	}

	mutating func encode(_ value: UInt) throws {
		result = value
	}

	mutating func encode(_ value: UInt8) throws {
		result = value
	}

	mutating func encode(_ value: UInt16) throws {
		result = value
	}

	mutating func encode(_ value: UInt32) throws {
		result = value
	}

	mutating func encode(_ value: UInt64) throws {
		result = value
	}

	mutating func encode(_ value: some Encodable) throws {
		let encoder = AnyValueEncoder(codingPath: codingPath, dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
		result = try encoder.encode(value).value
	}
}

private struct AnyValueKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {

	var codingPath: [CodingKey]
	let dateFormat: DateEncodingFormat
	let keyEncodingStrategy: KeyEncodingStrategy
	@Ref var result: [String: Any?]

	@inline(__always)
	private func str(_ key: Key) -> String {
		keyEncodingStrategy.encode(key.stringValue)
	}

	mutating func encodeNil(forKey key: Key) throws {
		result[str(key)] = nil
	}

	mutating func encode(_ value: Bool, forKey key: Key) throws {
		result[str(key)] = value
	}

	mutating func encode(_ value: String, forKey key: Key) throws {
		result[str(key)] = value
	}

	mutating func encode(_ value: Double, forKey key: Key) throws {
		result[str(key)] = value
	}

	mutating func encode(_ value: Float, forKey key: Key) throws {
		result[str(key)] = value
	}

	mutating func encode(_ value: Int, forKey key: Key) throws {
		result[str(key)] = value
	}

	mutating func encode(_ value: Int8, forKey key: Key) throws {
		result[str(key)] = value
	}

	mutating func encode(_ value: Int16, forKey key: Key) throws {
		result[str(key)] = value
	}

	mutating func encode(_ value: Int32, forKey key: Key) throws {
		result[str(key)] = value
	}

	mutating func encode(_ value: Int64, forKey key: Key) throws {
		result[str(key)] = value
	}

	mutating func encode(_ value: UInt, forKey key: Key) throws {
		result[str(key)] = value
	}

	mutating func encode(_ value: UInt8, forKey key: Key) throws {
		result[str(key)] = value
	}

	mutating func encode(_ value: UInt16, forKey key: Key) throws {
		result[str(key)] = value
	}

	mutating func encode(_ value: UInt32, forKey key: Key) throws {
		result[str(key)] = value
	}

	mutating func encode(_ value: UInt64, forKey key: Key) throws {
		result[str(key)] = value
	}

	mutating func encode(_ value: some Encodable, forKey key: Key) throws {
		let encoder = AnyValueEncoder(codingPath: nestedPath(for: key), dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
		result[str(key)] = try encoder.encode(value).value
	}

	mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
		let strKey = str(key)
		let container = AnyValueKeyedEncodingContainer<NestedKey>(
			codingPath: nestedPath(for: key),
			dateFormat: dateFormat,
			keyEncodingStrategy: keyEncodingStrategy,
			result: Ref { [$result] in
				guard
					let value = $result.wrappedValue[strKey] as? [String: Any?]
				else { return [:] }
				return value
			} set: { [$result] newValue in
				$result.wrappedValue[strKey] = newValue
			}
		)
		result[strKey] = [:] as [String: Any?]
		return KeyedEncodingContainer(container)
	}

	mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
		let strKey = str(key)
		let container = AnyValueUnkeyedEncodingContainer(
			codingPath: nestedPath(for: key),
			dateFormat: dateFormat,
			keyEncodingStrategy: keyEncodingStrategy,
			result: Ref { [$result] in
				guard
					let value = $result.wrappedValue[strKey] as? [Any?]
				else { return [] }
				return value
			} set: { [$result] newValue in
				$result.wrappedValue[strKey] = newValue
			}
		)
		result[strKey] = [] as [Any?]
		return container
	}

	mutating func superEncoder() -> Encoder {
		AnyValueEncoder(codingPath: codingPath, dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
	}

	mutating func superEncoder(forKey key: Key) -> Encoder {
		result[str(key)] = [:] as [String: Any?]
		return AnyValueEncoder(codingPath: nestedPath(for: key), dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
	}

	private func nestedPath(for key: Key) -> [CodingKey] {
		codingPath + [key]
	}
}

private struct AnyValueUnkeyedEncodingContainer: UnkeyedEncodingContainer {

	var codingPath: [CodingKey]
	var count: Int { result.count }
	let dateFormat: DateEncodingFormat
	let keyEncodingStrategy: KeyEncodingStrategy
	@Ref var result: [Any?]

	private var nestedPath: [CodingKey] {
		codingPath + [IntKey(intValue: codingPath.count)]
	}

	mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
		let index = result.count
		let container = AnyValueKeyedEncodingContainer<NestedKey>(
			codingPath: nestedPath,
			dateFormat: dateFormat,
			keyEncodingStrategy: keyEncodingStrategy,
			result: Ref { [$result] in
				guard
					$result.wrappedValue.indices.contains(index),
					let value = $result.wrappedValue[index] as? [String: Any?]
				else { return [:] }
				return value
			} set: { [$result] newValue in
				guard $result.wrappedValue.indices.contains(index) else {
					return
				}
				$result.wrappedValue[index] = newValue
			}
		)
		result.append([:] as [String: Any])
		return KeyedEncodingContainer(container)
	}

	mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
		let index = result.count
		let container = AnyValueUnkeyedEncodingContainer(
			codingPath: nestedPath,
			dateFormat: dateFormat,
			keyEncodingStrategy: keyEncodingStrategy,
			result: Ref { [$result] in
				guard
					$result.wrappedValue.indices.contains(index),
					let value = $result.wrappedValue[index] as? [Any?]
				else { return [] }
				return value
			} set: { [$result] newValue in
				guard $result.wrappedValue.indices.contains(index) else {
					return
				}
				$result.wrappedValue[index] = newValue
			}
		)
		result.append([] as [Any?])
		return container
	}

	mutating func encodeNil() throws {}

	mutating func superEncoder() -> Encoder {
		AnyValueEncoder(codingPath: codingPath, dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
	}

	mutating func encode(_ value: Bool) throws {
		result.append(value)
	}

	mutating func encode(_ value: String) throws {
		result.append(value)
	}

	mutating func encode(_ value: Double) throws {
		result.append(value)
	}

	mutating func encode(_ value: Float) throws {
		result.append(value)
	}

	mutating func encode(_ value: Int) throws {
		result.append(value)
	}

	mutating func encode(_ value: Int8) throws {
		result.append(value)
	}

	mutating func encode(_ value: Int16) throws {
		result.append(value)
	}

	mutating func encode(_ value: Int32) throws {
		result.append(value)
	}

	mutating func encode(_ value: Int64) throws {
		result.append(value)
	}

	mutating func encode(_ value: UInt) throws {
		result.append(value)
	}

	mutating func encode(_ value: UInt8) throws {
		result.append(value)
	}

	mutating func encode(_ value: UInt16) throws {
		result.append(value)
	}

	mutating func encode(_ value: UInt32) throws {
		result.append(value)
	}

	mutating func encode(_ value: UInt64) throws {
		result.append(value)
	}

	mutating func encode(_ value: some Encodable) throws {
		let encoder = AnyValueEncoder(codingPath: nestedPath, dateFormat: dateFormat, keyEncodingStrategy: keyEncodingStrategy)
		try result.append(encoder.encode(value).value)
	}
}
