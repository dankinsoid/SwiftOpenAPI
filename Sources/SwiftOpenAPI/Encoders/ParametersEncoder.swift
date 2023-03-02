import Foundation

final class ParametersEncoder: Encoder {
    
    var codingPath: [CodingKey] = []
    let dateFormat: DateEncodingFormat
    var location: ParameterObject.Location
    var userInfo: [CodingUserInfoKey: Any] = [:]
    var result: [ParameterObject] = []
    var schemas: [String: ReferenceOr<SchemaObject>] = [:]
    private var notKeyed = false
    
    init(in location: ParameterObject.Location, dateFormat: DateEncodingFormat) {
        self.location = location
        self.dateFormat = dateFormat
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        KeyedEncodingContainer(
            ParametersKeyedEncodingContainer(
                codingPath: codingPath,
                dateFormat: dateFormat,
                location: location,
                result: Ref(self, \.result),
                references: Ref(self, \.schemas)
            )
        )
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        notKeyed = true
        return AnyValueEncoder(dateFormat: dateFormat).unkeyedContainer()
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        notKeyed = true
        return AnyValueEncoder(dateFormat: dateFormat).singleValueContainer()
    }
    
    func encode(
        _ value: Encodable,
        schemas: inout [String: ReferenceOr<SchemaObject>]
    ) throws -> [ParameterObject] {
        try value.encode(to: self)
        guard !notKeyed else { throw Errors.invalidValue }
        schemas.merge(self.schemas) { _, new in new }
        return result
    }

    enum Errors: Error {
        
        case invalidValue
    }
}

private struct ParametersKeyedEncodingContainer<Key: CodingKey>: KeyedEncodingContainerProtocol {
    
    var codingPath: [CodingKey]
    let dateFormat: DateEncodingFormat
    var location: ParameterObject.Location
    @Ref var result: [ParameterObject]
    @Ref var references: [String: ReferenceOr<SchemaObject>]
    
    @inline(__always)
    private func str(_ key: Key) -> String {
        key.stringValue
    }
    
    mutating func encodeNil(forKey key: Key) throws {
    }
    
    mutating func encode(_ value: Bool, forKey key: Key) throws {
        try encode(.bool(value), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Bool?, forKey key: Key) throws {
        try encode(.bool(value ?? .random()), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: String, forKey key: Key) throws {
        try encode(.string(value), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: String?, forKey key: Key) throws {
        try encode(.string(value ?? "string value"), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: Double, forKey key: Key) throws {
        try encode(.double(value), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Double?, forKey key: Key) throws {
        try encode(.double(value ?? .random(in: 0...10)), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: Float, forKey key: Key) throws {
        try encode(.double(Double(value)), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Float?, forKey key: Key) throws {
        try encode(.double(value.map { Double($0) } ?? .random(in: 0...10)), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: Int, forKey key: Key) throws {
        try encode(.int(value), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Int?, forKey key: Key) throws {
        try encode(.int(value ?? .random(in: 0...1000)), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: Int8, forKey key: Key) throws {
        try encode(.int(Int(value)), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Int8?, forKey key: Key) throws {
        try encode(.int(value.map { Int($0) } ?? .random(in: 0...1000)), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: Int16, forKey key: Key) throws {
        try encode(.int(Int(value)), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Int16?, forKey key: Key) throws {
        try encode(.int(value.map { Int($0) } ?? .random(in: 0...1000)), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: Int32, forKey key: Key) throws {
        try encode(.int(Int(value)), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Int32?, forKey key: Key) throws {
        try encode(.int(value.map { Int($0) } ?? .random(in: 0...1000)), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: Int64, forKey key: Key) throws {
        try encode(.int(Int(value)), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: Int64?, forKey key: Key) throws {
        try encode(.int(value.map { Int($0) } ?? .random(in: 0...1000)), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: UInt, forKey key: Key) throws {
        try encode(.int(Int(value)), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: UInt?, forKey key: Key) throws {
        try encode(.int(value.map { Int($0) } ?? .random(in: 0...1000)), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        try encode(.int(Int(value)), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: UInt8?, forKey key: Key) throws {
        try encode(.int(value.map { Int($0) } ?? .random(in: 0...1000)), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        try encode(.int(Int(value)), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: UInt16?, forKey key: Key) throws {
        try encode(.int(value.map { Int($0) } ?? .random(in: 0...1000)), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        try encode(.int(Int(value)), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: UInt32?, forKey key: Key) throws {
        try encode(.int(value.map { Int($0) } ?? .random(in: 0...1000)), forKey: key, optional: true)
    }
    
    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        try encode(.int(Int(value)), forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent(_ value: UInt64?, forKey key: Key) throws {
        try encode(.int(value.map { Int($0) } ?? .random(in: 0...1000)), forKey: key, optional: true)
    }
    
    mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        try encode(value, forKey: key, optional: false)
    }
    
    mutating func encodeIfPresent<T>(_ value: T?, forKey key: Key) throws where T : Encodable {
        try encode(value, forKey: key, optional: true)
    }
    
    private mutating func encode<T>(_ value: T?, forKey key: Key, optional: Bool) throws where T : Encodable {
        let encoder = SchemeEncoder(codingPath: nestedPath(for: key), dateFormat: dateFormat)
        result.append(
            ParameterObject(
                name: str(key),
                in: location,
                required: !optional,
                schema: value.flatMap { try? encoder.encode($0, into: &references) },
                example: value.flatMap { try? .encode($0, dateFormat: dateFormat) }
            )
        )
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        SchemeEncoder(codingPath: nestedPath(for: key), dateFormat: dateFormat)
            .container(keyedBy: NestedKey.self)
    }
    
    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        SchemeEncoder(codingPath: nestedPath(for: key), dateFormat: dateFormat)
            .unkeyedContainer()
    }
    
    mutating func superEncoder() -> Encoder {
        SchemeEncoder(codingPath: codingPath, extractReferences: false, dateFormat: dateFormat)
    }
    
    mutating func superEncoder(forKey key: Key) -> Encoder {
        SchemeEncoder(codingPath: codingPath, extractReferences: false, dateFormat: dateFormat)
    }
    
    private func nestedPath(for key: Key) -> [CodingKey] {
        codingPath + [key]
    }
    
    @inline(__always)
    private mutating func encode(_ example: AnyValue, forKey key: Key, optional: Bool) throws {
        result.append(
        		ParameterObject(
                name: str(key),
                in: location,
                required: !optional,
                schema: .value(.primitive(example.dataType.asPrimitive ?? .string)),
                example: example
            )
        )
    }
}
