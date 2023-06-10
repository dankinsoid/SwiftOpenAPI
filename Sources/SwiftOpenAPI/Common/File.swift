import Foundation

extension Decimal {

	var double: Double {
		(self as NSDecimalNumber).doubleValue
	}
}
