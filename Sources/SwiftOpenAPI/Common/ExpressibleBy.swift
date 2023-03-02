import Foundation

public protocol ExpressibleByArray<ArrayLiteralElement>: ExpressibleByArrayLiteral {
    
    init(arrayElements elements: [ArrayLiteralElement])
}

extension ExpressibleByArrayLiteral where Self: ExpressibleByArray {
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(arrayElements: elements)
    }
}

public protocol MutableDictionary<Key, Value> {
    
    associatedtype Key: Hashable
    associatedtype Value
    
    subscript(_ key: Key) -> Value? { get set }
}

extension Dictionary: MutableDictionary {
}

public protocol ExpressibleByDictionary<Key, Value>: ExpressibleByDictionaryLiteral, MutableDictionary {
    
    init(dictionaryElements elements: [(Key, Value)])
}

extension ExpressibleByDictionaryLiteral where Self: ExpressibleByDictionary {
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(dictionaryElements: elements)
    }
}
