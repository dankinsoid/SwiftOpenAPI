import Foundation

struct IntKey: CodingKey {
	var intValue: Int?
	var stringValue: String {
		"\(intValue ?? 0)"
	}

	init(intValue: Int) {
		self.intValue = intValue
	}

	init(stringValue: String) {
		intValue = Int(stringValue)
	}
}

struct StringKey<Value: LosslessStringConvertible>: CodingKey {
	var stringValue: String { value.description }
	var intValue: Int? { nil }
	var value: Value

	init?(stringValue: String) {
		guard let value = Value(stringValue) else {
			return nil
		}
		self.value = value
	}

	init?(intValue _: Int) {
		nil
	}

	init(_ value: Value) {
		self.value = value
	}
}
