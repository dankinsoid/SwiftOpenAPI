import Foundation

final class CheckAllKeysDecoder: Decoder {
    
    var codingPath: [CodingKey] = []
    var userInfo: [CodingUserInfoKey: Any] = [:]
    var isAdditional = false
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
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
    func contains(_ key: Key) -> Bool { false }
    func decodeNil(forKey key: Key) throws -> Bool { throw AnyError() }
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool { throw AnyError() }
    func decode(_ type: String.Type, forKey key: Key) throws -> String { throw AnyError() }
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double { throw AnyError() }
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float { throw AnyError() }
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int { throw AnyError() }
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 { throw AnyError() }
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 { throw AnyError() }
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 { throw AnyError() }
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 { throw AnyError() }
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt { throw AnyError() }
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 { throw AnyError() }
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 { throw AnyError() }
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 { throw AnyError() }
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 { throw AnyError() }
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable { throw AnyError() }
    func nestedContainer<NestedKey: CodingKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> { throw AnyError() }
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer { throw AnyError() }
    func superDecoder() throws -> Decoder { throw AnyError() }
    func superDecoder(forKey key: Key) throws -> Decoder { throw AnyError() }
}

private struct AnyError: Error {
}
