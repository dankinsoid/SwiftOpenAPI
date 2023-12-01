import Foundation

public protocol OpenAPIDescriptable {
    
    static var openAPIDescription: OpenAPIDescriptionType? { get }
}

public extension OpenAPIDescriptable {
    
    static var openAPIDescription: OpenAPIDescriptionType? {
        nil
    }
}
