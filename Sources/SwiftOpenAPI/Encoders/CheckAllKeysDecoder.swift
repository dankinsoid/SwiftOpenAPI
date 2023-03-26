import Foundation

final class CheckAllKeysDecoder: Decoder {

	var codingPath: [CodingKey] = []
	var userInfo: [CodingUserInfoKey: Any] = [:]
	var isAdditional = false

	func container<Key>(keyedBy _: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
		KeyedDecodingContainer(
			CheckAllKeysDecodingContainer(isAdditional: Ref(self, \.isAdditional))
		)
	}

	func unkeyedContainer() throws -> UnkeyedDecodingContainer { throw AnyError() }
	func singleValueContainer() throws -> SingleValueDecodingContainer { throw AnyError() }
}

private struct CheckAllKeysDecodingContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {

	var allKeys: [Key] {
		isAdditional = true
		return []
	}

	@Ref var isAdditional: Bool

	var codingPath: [CodingKey] { [] }
	func contains(_: Key) -> Bool { false }
	func decodeNil(forKey _: Key) throws -> Bool { throw AnyError() }
	func decode(_: Bool.Type, forKey _: Key) throws -> Bool { throw AnyError() }
	func decode(_: String.Type, forKey _: Key) throws -> String { throw AnyError() }
	func decode(_: Double.Type, forKey _: Key) throws -> Double { throw AnyError() }
	func decode(_: Float.Type, forKey _: Key) throws -> Float { throw AnyError() }
	func decode(_: Int.Type, forKey _: Key) throws -> Int { throw AnyError() }
	func decode(_: Int8.Type, forKey _: Key) throws -> Int8 { throw AnyError() }
	func decode(_: Int16.Type, forKey _: Key) throws -> Int16 { throw AnyError() }
	func decode(_: Int32.Type, forKey _: Key) throws -> Int32 { throw AnyError() }
	func decode(_: Int64.Type, forKey _: Key) throws -> Int64 { throw AnyError() }
	func decode(_: UInt.Type, forKey _: Key) throws -> UInt { throw AnyError() }
	func decode(_: UInt8.Type, forKey _: Key) throws -> UInt8 { throw AnyError() }
	func decode(_: UInt16.Type, forKey _: Key) throws -> UInt16 { throw AnyError() }
	func decode(_: UInt32.Type, forKey _: Key) throws -> UInt32 { throw AnyError() }
	func decode(_: UInt64.Type, forKey _: Key) throws -> UInt64 { throw AnyError() }
	func decode<T>(_: T.Type, forKey _: Key) throws -> T where T: Decodable { throw AnyError() }
	func nestedContainer<NestedKey: CodingKey>(keyedBy _: NestedKey.Type, forKey _: Key) throws -> KeyedDecodingContainer<NestedKey> { throw AnyError() }
	func nestedUnkeyedContainer(forKey _: Key) throws -> UnkeyedDecodingContainer { throw AnyError() }
	func superDecoder() throws -> Decoder { throw AnyError() }
	func superDecoder(forKey _: Key) throws -> Decoder { throw AnyError() }
}

private struct AnyError: Error {}
