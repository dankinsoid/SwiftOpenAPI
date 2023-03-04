import Foundation

struct TypeInfo {
    
    static let any = TypeInfo(type: Any.self, container: .single(.null))
    
    var type: Any.Type
    var isOptional: Bool = false
    var container: CodableContainerValue
}

struct KeyedInfo {
    
    var fields: [String: TypeInfo] = [:]
    var isFixed: Bool = true
    
    subscript(_ key: String) -> TypeInfo {
        get { fields[key] ?? .any }
        set { fields[key] = newValue }
    }
}

indirect enum CodableContainerValue {
    
    case single(CodableValues)
    case keyed(KeyedInfo)
    case unkeyed(TypeInfo)
    case recursive
    
    var keyed: KeyedInfo {
        get {
            if case let .keyed(info) = self {
                return info
            }
            return KeyedInfo()
        }
        set {
            self = .keyed(newValue)
        }
    }
    
    var unkeyed: TypeInfo? {
        get {
            if case let .unkeyed(value) = self {
                return value
            }
            return nil
        }
        set {
            if let newValue {
                self = .unkeyed(newValue)
            }
        }
    }
    
    var single: CodableValues? {
        get {
            if case let .single(value) = self {
                return value
            }
            return nil
        }
        set {
            if let newValue {
                self = .single(newValue)
            }
        }
    }
}

enum CodableValues: Equatable {
    
    case int(Int?)
    case int8(Int8?)
    case int16(Int16?)
    case int32(Int32?)
    case int64(Int64?)
    case uint(UInt?)
    case uint8(UInt8?)
    case uint16(UInt16?)
    case uint32(UInt32?)
    case uint64(UInt64?)
    case double(Double?)
    case float(Float?)
    case bool(Bool?)
    case string(String?)
    case null
    
    var type: Any.Type {
        switch self {
        case .int: return Int.self
        case .int8: return Int8.self
        case .int16: return Int16.self
        case .int32: return Int32.self
        case .int64: return Int64.self
        case .uint: return UInt.self
        case .uint8: return UInt8.self
        case .uint16: return UInt16.self
        case .uint32: return UInt32.self
        case .uint64: return UInt64.self
        case .double: return Double.self
        case .float: return Float.self
        case .bool: return Bool.self
        case .string: return String.self
        case .null: return Any.self
        }
    }
}

extension CodableContainerValue {
    
    var anyValue: AnyValue? {
        switch self {
        case .single(let codableValues):
            switch codableValues {
            case .int(let value): return value.map { .int($0) }
            case .int8(let value): return value.map { .int(Int($0)) }
            case .int16(let value): return value.map { .int(Int($0)) }
            case .int32(let value): return value.map { .int(Int($0)) }
            case .int64(let value): return value.map { .int(Int($0)) }
            case .uint(let value): return value.map { .int(Int($0)) }
            case .uint8(let value): return value.map { .int(Int($0)) }
            case .uint16(let value): return value.map { .int(Int($0)) }
            case .uint32(let value): return value.map { .int(Int($0)) }
            case .uint64(let value): return value.map { .int(Int($0)) }
            case .double(let value): return value.map { .double($0) }
            case .float(let value): return value.map { .double(Double($0)) }
            case .bool(let value): return value.map { .bool($0) }
            case .string(let value): return value.map { .string($0) }
            case .null: return nil
            }
            
        case .keyed(let keyedInfo):
            return .object(keyedInfo.fields.compactMapValues(\.container.anyValue))
            
        case .unkeyed(let typeInfo):
            return typeInfo.container.anyValue.map { .array([$0]) }
            
        case .recursive:
            return nil
        }
    }
}
