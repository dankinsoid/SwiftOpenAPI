import Foundation

extension Bool {

	var nilIfFalse: Bool? {
		self ? self : nil
	}
}
