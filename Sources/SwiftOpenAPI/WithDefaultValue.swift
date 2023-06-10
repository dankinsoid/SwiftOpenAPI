import Foundation

@attached(member, names: named(defaultValues))
public macro CollectDefaultValues() = #externalMacro(module: "SwiftOpenAPIMacros", type: "DefaultValuesMacro")

public protocol WithDefaultValues {
    
    static var defaultValues: DefaultValues { get }
}

extension WithDefaultValues {
    
    public static var defaultValues: DefaultValues { DefaultValues() }
}

public struct DefaultValues {
    
    public var values: [String: AnyValue] = [:]
    
    public init() {
    }
    
    public func add(_ key: CodingKey, _ value: Encodable) -> DefaultValues {
        guard let value = try? AnyValue.encode(value) else { return self }
        var result = self
        result.values[key.stringValue] = value
        return result
    }
}
