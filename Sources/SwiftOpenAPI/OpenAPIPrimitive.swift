import Foundation

public protocol OpenAPIType {
    
    static var openAPISchema: SchemaObject { get }
}

extension OpenAPIType {
    
    static var isPrimitive: Bool {
        if case .primitive = openAPISchema {
            return true
        }
        return false
    }
}

extension String: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.string) }
}

extension StaticString: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.string) }
}

extension Int: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.integer) }
}

extension Int8: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.integer) }
}

extension Int16: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.integer) }
}

extension Int32: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.integer) }
}

extension Int64: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.integer) }
}

extension UInt: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.integer) }
}

extension UInt8: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.integer) }
}

extension UInt16: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.integer) }
}

extension UInt32: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.integer) }
}

extension UInt64: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.integer) }
}

extension Double: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.number) }
}

extension Float: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.number) }
}

extension Decimal: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.number) }
}

extension Date: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.string, format: .dateTime) }
}

extension UUID: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.string, format: .uuid) }
}

extension Optional: OpenAPIType where Wrapped: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { Wrapped.openAPISchema }
}
