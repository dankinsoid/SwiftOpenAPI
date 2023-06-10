import Foundation

public enum DataType: String, Codable {

	case string
	case number
	case integer
	case boolean
	case array
	case object

	public var asPrimitive: PrimitiveDataType? {
		switch self {
		case .string: return .string
		case .number: return .number
		case .integer: return .integer
		case .boolean: return .boolean
		case .array, .object: return nil
		}
	}
}

public enum PrimitiveDataType: String, Codable {

	case string
	case number
	case integer
	case boolean

	public var asDataType: DataType {
		switch self {
		case .string: return .string
		case .number: return .number
		case .integer: return .integer
		case .boolean: return .boolean
		}
	}
}
