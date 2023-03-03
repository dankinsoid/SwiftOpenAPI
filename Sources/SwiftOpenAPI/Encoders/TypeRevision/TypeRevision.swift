import Foundation

struct TypeRevision {
    
    let customDescription: (Any.Type, Any?) -> CodableContainerValue?
    
    init(custom: @escaping (Any.Type, Any?) -> CodableContainerValue?) {
        customDescription = custom
    }
    
    init() {
        self.init { _, _ in nil }
    }
    
    func describeType(of value: Encodable) throws -> CodableContainerValue {
        let encoder = TypeRevisionEncoder(context: self)
        try encoder.encode(value, type: type(of: value))
        return encoder.result.container
    }
    
    func describe(type: Decodable.Type) throws -> CodableContainerValue {
        let decoder = TypeRevisionDecoder(context: self)
        try decoder.decode(type)
        return decoder.result.container
    }
}
