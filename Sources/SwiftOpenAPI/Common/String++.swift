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
}
