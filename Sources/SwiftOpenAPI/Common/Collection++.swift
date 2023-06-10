import Foundation

extension Collection {

	var nilIfEmpty: Self? {
		isEmpty ? nil : self
	}
}

extension OrderedDictionary {

	func mapKeys<T>(_ map: (Key) -> T) -> OrderedDictionary<T, Value> {
		OrderedDictionary<T, Value>(self.map { (map($0.key), $0.value) }) { _, new in
			new
		}
	}

	func mapKeys<T, V>(_ map: (Key) -> T, values: (Value) -> V) -> OrderedDictionary<T, V> {
		OrderedDictionary<T, V>(self.map { (map($0.key), values($0.value)) }) { _, new in
			new
		}
	}
}
