import Foundation

final class AnyValueEncoder: Encoder {
	var codingPath: [CodingKey]
	var userInfo: [CodingUserInfoKey: Any]
	var result: AnyValue
	var dateFormat: DateEncodingFormat

	init(
		codingPath: [CodingKey] = [],
		dateFormat: DateEncodingFormat
	) {
		self.codingPath = codingPath
		userInfo = [:]
		self.dateFormat = dateFormat
		result = .object([:])
	}

	func container<Key>(keyedBy _: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
		let container = AnyValueKeyedEncodingContainer<Key>(
			codingPath: codingPath,
			dateFormat: dateFormat,
			result: Ref { [self] in
				guard case let .object(value) = result else { return [:] }
				return value
			} set: { [self] newValue in
				result = .object(newValue)
			}
		)
		return KeyedEncodingContainer(container)
	}

	func unkeyedContainer() -> UnkeyedEncodingContainer {
		AnyValueUnkeyedEncodingContainer(
			codingPath: codingPath,
			dateFormat: dateFormat,
			result: Ref { [self] in
				if case let .array(value) = result {
					return value
				}
				return []
			} set: { [self] newValue in
				result = .array(newValue)
			}
		)
	}

	func singleValueContainer() -> SingleValueEncodingContainer {
		AnyValueSingleValueEncodingContainer(
			codingPath: codingPath,
			dateFormat: dateFormat,
			result: Ref(self, \.result)
		)
	}

	func encode(_ value: Encodable) throws -> AnyValue {
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
	@Ref var result: AnyValue

	mutating func encodeNil() throws {}

	mutating func encode(_ value: Bool) throws {
		result = .bool(value)
	}

	mutating func encode(_ value: String) throws {
		result = .string(value)
	}

	mutating func encode(_ value: Double) throws {
		result = .double(value)
	}

	mutating func encode(_ value: Float) throws {
		result = .double(Double(value))
	}

	mutating func encode(_ value: Int) throws {
		result = .int(value)
	}

	mutating func encode(_ value: Int8) throws {
		result = .int(Int(value))
	}

	mutating func encode(_ value: Int16) throws {
		result = .int(Int(value))
	}

	mutating func encode(_ value: Int32) throws {
		result = .int(Int(value))
	}

	mutating func encode(_ value: Int64) throws {
		result = .int(Int(value))
	}

	mutating func encode(_ value: UInt) throws {
		result = .int(Int(value))
	}

	mutating func encode(_ value: UInt8) throws {
		result = .int(Int(value))
	}

	mutating func encode(_ value: UInt16) throws {
		result = .int(Int(value))
	}

	mutating func encode(_ value: UInt32) throws {
		result = .int(Int(value))
	}

	mutating func encode(_ value: UInt64) throws {
		result = .int(Int(value))
	}

	mutating func encode(_ value: some Encodable) throws {
		let encoder = AnyValueEncoder(codingPath: codingPath, dateFormat: dateFormat)
		result = try encoder.encode(value)
	}
}

private struct AnyValueKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
	var codingPath: [CodingKey]
	let dateFormat: DateEncodingFormat
	@Ref var result: [String: AnyValue]

	@inline(__always)
	private func str(_ key: Key) -> String {
		key.stringValue
	}

	mutating func encodeNil(forKey key: Key) throws {
		result[str(key)] = nil
	}

	mutating func encode(_ value: Bool, forKey key: Key) throws {
		result[str(key)] = .bool(value)
	}

	mutating func encode(_ value: String, forKey key: Key) throws {
		result[str(key)] = .string(value)
	}

	mutating func encode(_ value: Double, forKey key: Key) throws {
		result[str(key)] = .double(value)
	}

	mutating func encode(_ value: Float, forKey key: Key) throws {
		result[str(key)] = .double(Double(value))
	}

	mutating func encode(_ value: Int, forKey key: Key) throws {
		result[str(key)] = .int(value)
	}

	mutating func encode(_ value: Int8, forKey key: Key) throws {
		result[str(key)] = .int(Int(value))
	}

	mutating func encode(_ value: Int16, forKey key: Key) throws {
		result[str(key)] = .int(Int(value))
	}

	mutating func encode(_ value: Int32, forKey key: Key) throws {
		result[str(key)] = .int(Int(value))
	}

	mutating func encode(_ value: Int64, forKey key: Key) throws {
		result[str(key)] = .int(Int(value))
	}

	mutating func encode(_ value: UInt, forKey key: Key) throws {
		result[str(key)] = .int(Int(value))
	}

	mutating func encode(_ value: UInt8, forKey key: Key) throws {
		result[str(key)] = .int(Int(value))
	}

	mutating func encode(_ value: UInt16, forKey key: Key) throws {
		result[str(key)] = .int(Int(value))
	}

	mutating func encode(_ value: UInt32, forKey key: Key) throws {
		result[str(key)] = .int(Int(value))
	}

	mutating func encode(_ value: UInt64, forKey key: Key) throws {
		result[str(key)] = .int(Int(value))
	}

	mutating func encode(_ value: some Encodable, forKey key: Key) throws {
		let encoder = AnyValueEncoder(codingPath: nestedPath(for: key), dateFormat: dateFormat)
		result[str(key)] = try encoder.encode(value)
	}

	mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
		let strKey = str(key)
		let container = AnyValueKeyedEncodingContainer<NestedKey>(
			codingPath: nestedPath(for: key),
			dateFormat: dateFormat,
			result: Ref { [$result] in
				guard
					case let .object(value) = $result.wrappedValue[strKey]
				else { return [:] }
				return value
			} set: { [$result] newValue in
				$result.wrappedValue[strKey] = .object(newValue)
			}
		)
		result[strKey] = .object([:])
		return KeyedEncodingContainer(container)
	}

	mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
		let strKey = str(key)
		let container = AnyValueUnkeyedEncodingContainer(
			codingPath: nestedPath(for: key),
			dateFormat: dateFormat,
			result: Ref { [$result] in
				guard
					case let .array(value) = $result.wrappedValue[strKey]
				else { return [] }
				return value
			} set: { [$result] newValue in
				$result.wrappedValue[strKey] = .array(newValue)
			}
		)
		result[strKey] = .array([])
		return container
	}

	mutating func superEncoder() -> Encoder {
		AnyValueEncoder(codingPath: codingPath, dateFormat: dateFormat)
	}

	mutating func superEncoder(forKey key: Key) -> Encoder {
		result[str(key)] = .object([:])
		return AnyValueEncoder(codingPath: nestedPath(for: key), dateFormat: dateFormat)
	}

	private func nestedPath(for key: Key) -> [CodingKey] {
		codingPath + [key]
	}
}

private struct AnyValueUnkeyedEncodingContainer: UnkeyedEncodingContainer {
	var codingPath: [CodingKey]
	var count: Int { result.count }
	let dateFormat: DateEncodingFormat
	@Ref var result: [AnyValue]

	private var nestedPath: [CodingKey] {
		codingPath + [IntKey(intValue: codingPath.count)]
	}

	mutating func nestedContainer<NestedKey>(keyedBy _: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
		let index = result.count
		let container = AnyValueKeyedEncodingContainer<NestedKey>(
			codingPath: nestedPath,
			dateFormat: dateFormat,
			result: Ref { [$result] in
				guard
					$result.wrappedValue.indices.contains(index),
					case let .object(value) = $result.wrappedValue[index]
				else { return [:] }
				return value
			} set: { [$result] newValue in
				guard $result.wrappedValue.indices.contains(index) else {
					return
				}
				$result.wrappedValue[index] = .object(newValue)
			}
		)
		result.append(.object([:]))
		return KeyedEncodingContainer(container)
	}

	mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
		let index = result.count
		let container = AnyValueUnkeyedEncodingContainer(
			codingPath: nestedPath,
			dateFormat: dateFormat,
			result: Ref { [$result] in
				guard
					$result.wrappedValue.indices.contains(index),
					case let .array(value) = $result.wrappedValue[index]
				else { return [] }
				return value
			} set: { [$result] newValue in
				guard $result.wrappedValue.indices.contains(index) else {
					return
				}
				$result.wrappedValue[index] = .array(newValue)
			}
		)
		result.append(.array([]))
		return container
	}

	mutating func encodeNil() throws {}

	mutating func superEncoder() -> Encoder {
		AnyValueEncoder(codingPath: codingPath, dateFormat: dateFormat)
	}

	mutating func encode(_ value: Bool) throws {
		result.append(.bool(value))
	}

	mutating func encode(_ value: String) throws {
		result.append(.string(value))
	}

	mutating func encode(_ value: Double) throws {
		result.append(.double(value))
	}

	mutating func encode(_ value: Float) throws {
		result.append(.double(Double(value)))
	}

	mutating func encode(_ value: Int) throws {
		result.append(.int(value))
	}

	mutating func encode(_ value: Int8) throws {
		result.append(.int(Int(value)))
	}

	mutating func encode(_ value: Int16) throws {
		result.append(.int(Int(value)))
	}

	mutating func encode(_ value: Int32) throws {
		result.append(.int(Int(value)))
	}

	mutating func encode(_ value: Int64) throws {
		result.append(.int(Int(value)))
	}

	mutating func encode(_ value: UInt) throws {
		result.append(.int(Int(value)))
	}

	mutating func encode(_ value: UInt8) throws {
		result.append(.int(Int(value)))
	}

	mutating func encode(_ value: UInt16) throws {
		result.append(.int(Int(value)))
	}

	mutating func encode(_ value: UInt32) throws {
		result.append(.int(Int(value)))
	}

	mutating func encode(_ value: UInt64) throws {
		result.append(.int(Int(value)))
	}

	mutating func encode(_ value: some Encodable) throws {
		let encoder = AnyValueEncoder(codingPath: nestedPath, dateFormat: dateFormat)
		try result.append(encoder.encode(value))
	}
}
