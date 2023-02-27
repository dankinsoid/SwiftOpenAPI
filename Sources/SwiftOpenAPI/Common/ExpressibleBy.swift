import Foundation

public protocol ExpressibleByArray<ArrayLiteralElement>: ExpressibleByArrayLiteral {
    
    init(arrayElements elements: [ArrayLiteralElement])
}

extension ExpressibleByArrayLiteral where Self: ExpressibleByArray {
    
    public init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(arrayElements: elements)
    }
}

public protocol ExpressibleByDictionary<Key, Value>: ExpressibleByDictionaryLiteral {
    
    init(dictionaryElements elements: [(Key, Value)])
}

extension ExpressibleByDictionaryLiteral where Self: ExpressibleByDictionary {
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(dictionaryElements: elements)
    }
}
