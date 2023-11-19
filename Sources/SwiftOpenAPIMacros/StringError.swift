import Foundation

struct StringError: LocalizedError {
    
    var errorDescription: String?
    
    init(_ errorDescription: String? = nil) {
        self.errorDescription = errorDescription
    }
}
