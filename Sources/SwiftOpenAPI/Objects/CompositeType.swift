import Foundation

public enum CompositeType: String, CodingKey {

	case oneOf, allOf, anyOf, not
}
