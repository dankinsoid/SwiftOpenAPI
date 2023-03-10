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
    
    public static var openAPISchema: SchemaObject { .primitive(.integer, format: "int64") }
}

extension Int8: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.integer, format: "int8") }
}

extension Int16: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.integer, format: "int16") }
}

extension Int32: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.integer, format: "int32") }
}

extension Int64: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.integer, format: "int64") }
}

extension UInt: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.integer, format: "uint64") }
}

extension UInt8: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.integer, format: "uint8") }
}

extension UInt16: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.integer, format: "uint16") }
}

extension UInt32: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.integer, format: "uint32") }
}

extension UInt64: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.integer, format: "uint64") }
}

extension Double: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.number, format: "double") }
}

extension Float: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.number, format: "float") }
}

extension Decimal: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.number, format: "decimal") }
}

extension Date: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.string, format: .dateTime) }
}

extension Data: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.string, format: .byte) }
}

extension UUID: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.string, format: .uuid) }
}

extension URL: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { .primitive(.string, format: .uri) }
}

extension Optional: OpenAPIType where Wrapped: OpenAPIType {
    
    public static var openAPISchema: SchemaObject { Wrapped.openAPISchema }
}
