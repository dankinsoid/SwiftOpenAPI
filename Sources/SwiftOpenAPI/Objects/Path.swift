import Foundation

public struct Path: Hashable, ExpressibleByStringInterpolation, LosslessStringConvertible, ExpressibleByArray {

	public typealias ArrayLiteralElement = PathElement

	public var path: [PathElement]
	public var stringValue: String {
		"/" + path.map(\.string).joined(separator: "/")
	}

	public var description: String {
		stringValue
	}

	public init(_ stringValue: String) {
		path = stringValue
			.components(separatedBy: ["/"])
			.lazy
			.filter { !$0.isEmpty }
			.map {
				PathElement($0)
			}
	}

	public init(_ path: [PathElement]) {
		self.path = path
	}

	public init(stringLiteral value: String) {
		self.init(value)
	}

	public init(arrayElements elements: [PathElement]) {
		self.init(elements)
	}

	public init(stringInterpolation value: DefaultStringInterpolation) {
		self.init(String(stringInterpolation: value))
	}
}

public enum PathElement: Hashable, ExpressibleByStringLiteral {
	case constant(String)
	case variable(String)

	public var string: String {
		switch self {
		case let .constant(string):
			return string
		case let .variable(string):
			return "{\(string)}"
		}
	}

	public init(stringLiteral value: String) {
		self.init(value)
	}

	public init(_ string: String) {
		if string.hasPrefix("{") || string.hasSuffix("}") {
			self = .variable(string.trimmingCharacters(in: ["{", "}"]))
		} else {
			self = .constant(string)
		}
	}
}

public extension PathElement {
	static let components: PathElement = "components"
}
