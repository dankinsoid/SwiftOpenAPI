import Foundation

public protocol ExpressibleByArray<ArrayLiteralElement>: ExpressibleByArrayLiteral {
	init(arrayElements elements: [ArrayLiteralElement])
}

public extension ExpressibleByArrayLiteral where Self: ExpressibleByArray {

	init(arrayLiteral elements: ArrayLiteralElement...) {
		self.init(arrayElements: elements)
	}
}

public protocol MutableDictionary<Key, Value> {
	associatedtype Key: Hashable
	associatedtype Value

	subscript(_: Key) -> Value? { get set }
}

extension Dictionary: MutableDictionary {}

public protocol ExpressibleByDictionary<Key, Value>: ExpressibleByDictionaryLiteral, MutableDictionary {
	init(dictionaryElements elements: [(Key, Value)])
}

public extension ExpressibleByDictionaryLiteral where Self: ExpressibleByDictionary {

	init(dictionaryLiteral elements: (Key, Value)...) {
		self.init(dictionaryElements: elements)
	}
}
