import Foundation

public enum ReferenceOr<Object: Codable & Equatable>: Equatable, Codable {
    
    case value(Object)
    case ref(ReferenceObject)
    
    public init(from decoder: Decoder) throws {
        do {
            self = try .ref(ReferenceObject(from: decoder))
        } catch {
            self = try .value(Object(from: decoder))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .value(object):
            try object.encode(to: encoder)
        case let .ref(referenceObject):
            try referenceObject.encode(to: encoder)
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

extension ReferenceOr: ExpressibleByDictionary where Object: ExpressibleByDictionary {
    
    public init(dictionaryElements elements: [(Object.Key, Object.Value)]) {
        self = .value(Object(dictionaryElements: elements))
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
        .ref(components: keyPath, .typeName(type))
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
    \.securitySchemes: "securitySchemes"
]
