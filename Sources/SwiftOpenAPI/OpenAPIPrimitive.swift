import Foundation

public protocol OpenAPIPrimitive {
    
    static var openAPIFormat: String? { get }
}

extension OpenAPIPrimitive {
    
    public static var openAPIFormat: String? { nil }
}

extension String: OpenAPIPrimitive {}
extension StaticString: OpenAPIPrimitive {}
extension Int: OpenAPIPrimitive {}
extension Int8: OpenAPIPrimitive {}
extension Int16: OpenAPIPrimitive {}
extension Int32: OpenAPIPrimitive {}
extension Int64: OpenAPIPrimitive {}
extension UInt: OpenAPIPrimitive {}
extension UInt8: OpenAPIPrimitive {}
extension UInt16: OpenAPIPrimitive {}
extension UInt32: OpenAPIPrimitive {}
extension UInt64: OpenAPIPrimitive {}
extension Double: OpenAPIPrimitive {}
extension Float: OpenAPIPrimitive {}
extension Decimal: OpenAPIPrimitive {}
extension Data: OpenAPIPrimitive {}
extension Date: OpenAPIPrimitive {}

extension UUID: OpenAPIPrimitive {
    
    public static var openAPIFormat: String? { "uuid" }
}

extension Optional: OpenAPIPrimitive where Wrapped: OpenAPIPrimitive {
    
    public static var openAPIFormat: String? { Wrapped.openAPIFormat }
}
