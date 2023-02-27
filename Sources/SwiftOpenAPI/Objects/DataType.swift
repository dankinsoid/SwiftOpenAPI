import Foundation

public enum DataType: String, Codable {
    
	case string
	case number
	case integer
	case boolean
	case array
	case object
}

public enum PrimitiveDataType: String, Codable {
    
    case string
    case number
    case integer
    case boolean
}
