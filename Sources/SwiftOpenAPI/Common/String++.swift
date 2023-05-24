import Foundation

extension String {

	static func typeName(_ type: Any.Type) -> String {
		String(reflecting: type)
			.components(separatedBy: ["<", ",", " ", ">", ":", "[", "]", "?"])
			.lazy
			.flatMap {
				var result = $0.components(separatedBy: ["."])
				if result.count > 1 {
					result.removeFirst()
				}
				return result
			}
			.flatMap {
				$0.components(separatedBy: .alphanumerics.inverted)
			}
			.joined()
	}

	func toCamelCase(separator: String = "_") -> String {
		var result = ""

		for word in components(separatedBy: separator) {
			if result.isEmpty {
				// keep the first word in lowercase
				result += word.lowercased()
			} else {
				// capitalize the first character of the remaining words
				result += word.capitalized
			}
		}
		return result
	}

	func toSnakeCase(separator: String = "_") -> String {
		var result = ""

		for character in self {
			if character.isUppercase {
				result += separator + character.lowercased()
			} else {
				result += String(character)
			}
		}

		return result
	}
}
