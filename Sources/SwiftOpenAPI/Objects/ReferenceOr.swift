import Foundation

public enum ReferenceOr<Object: Codable & Equatable>: Equatable, Codable {
    
    case object(Object)
    case ref(ReferenceObject)
    
    public init(from decoder: Decoder) throws {
        do {
            self = try .ref(ReferenceObject(from: decoder))
        } catch {
            self = try .object(Object(from: decoder))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .object(object):
            try object.encode(to: encoder)
        case let .ref(referenceObject):
            try referenceObject.encode(to: encoder)
        }
    }
}

extension ReferenceOr: ExpressibleByUnicodeScalarLiteral where Object: ExpressibleByUnicodeScalarLiteral {
    
    public init(unicodeScalarLiteral value: Object.UnicodeScalarLiteralType) {
        self = .object(Object(unicodeScalarLiteral: value))
    }
}

extension ReferenceOr: ExpressibleByExtendedGraphemeClusterLiteral where Object: ExpressibleByExtendedGraphemeClusterLiteral {
    
    public init(extendedGraphemeClusterLiteral value: Object.ExtendedGraphemeClusterLiteralType) {
        self = .object(Object(extendedGraphemeClusterLiteral: value))
    }
}

extension ReferenceOr: ExpressibleByStringLiteral where Object: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: Object.StringLiteralType) {
        self = .object(Object(stringLiteral: value))
    }
}

extension ReferenceOr: ExpressibleByFloatLiteral where Object: ExpressibleByFloatLiteral {
    
    public init(floatLiteral value: Object.FloatLiteralType) {
        self = .object(Object(floatLiteral: value))
    }
}

extension ReferenceOr: ExpressibleByIntegerLiteral where Object: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: Object.IntegerLiteralType) {
        self = .object(Object(integerLiteral: value))
    }
}

extension ReferenceOr: ExpressibleByBooleanLiteral where Object: ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral value: Object.BooleanLiteralType) {
        self = .object(Object(booleanLiteral: value))
    }
}

extension ReferenceOr: ExpressibleByStringInterpolation where Object: ExpressibleByStringInterpolation {

    public init(stringInterpolation value: Object.StringInterpolation) {
        self = .object(Object(stringInterpolation: value))
    }
}

extension ReferenceOr: ExpressibleByArrayLiteral where Object: ExpressibleByArray {
    
    public init(arrayLiteral elements: Object.ArrayLiteralElement...) {
        self = .object(Object(arrayElements: elements))
    }
}

extension ReferenceOr: ExpressibleByArray where Object: ExpressibleByArray {
    
    public init(arrayElements elements: [Object.ArrayLiteralElement]) {
        self = .object(Object(arrayElements: elements))
    }
}

extension ReferenceOr: ExpressibleByDictionaryLiteral where Object: ExpressibleByDictionary {
    
    public init(dictionaryLiteral elements: (Object.Key, Object.Value)...) {
        self = .object(Object(dictionaryElements: elements))
    }
}

extension ReferenceOr: ExpressibleByDictionary where Object: ExpressibleByDictionary {
    
    public init(dictionaryElements elements: [(Object.Key, Object.Value)]) {
        self = .object(Object(dictionaryElements: elements))
    }
}

public extension ReferenceOr {
    
    static func ref(components keyPath: WritableKeyPath<ComponentsObject, [String: ReferenceOr<Object>]?>, _ name: String) -> ReferenceOr {
        let path: String
        if let name = names[keyPath] {
            path = name
        } else {
            var object = ComponentsObject()
            object[keyPath: keyPath] = [:]
            let anyValue = AnyValue.encode(object)
            switch anyValue {
            case .object(let dictionary):
                path = dictionary.keys.first ?? "schemas"
            default:
                path = "schemas"
            }
            names[keyPath] = path
        }
        return .ref(components: path, name)
    }
    
    static func ref(components keyPath: WritableKeyPath<ComponentsObject, [String: ReferenceOr<Object>]?>, _ type: Any.Type) -> ReferenceOr {
        .ref(components: keyPath, String(describing: type))
    }
}

private var names: [PartialKeyPath<ComponentsObject>: String] = [:]
