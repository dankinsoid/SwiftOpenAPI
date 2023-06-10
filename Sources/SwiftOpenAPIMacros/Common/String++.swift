import Foundation

extension String {
    var quoted: String {
        "\"\(self)\""
    }
    
    var fullQuoted: String {
        "\"\"\"\n\(self)\n\"\"\""
    }
}
