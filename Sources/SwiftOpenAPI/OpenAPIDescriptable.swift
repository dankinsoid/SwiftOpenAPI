import Foundation

@attached(member, names: named(openAPIDescription))
public macro CollectDocComments() = #externalMacro(module: "SwiftOpenAPIMacros", type: "DescriptableMacro")

public protocol OpenAPIDescriptable {
    
    static var openAPIDescription: OpenAPIDescriptionType? { get }
}

public extension OpenAPIDescriptable {
    
    static var openAPIDescription: OpenAPIDescriptionType? {
        nil
    }
}
