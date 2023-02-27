import Foundation

/// Adds metadata to a single tag that is used by the ```OperationObject```. It is not mandatory to have a Tag Object per tag defined in the Operation Object instances.
public struct TagObject: Codable, Equatable, SpecificationExtendable, Identifiable {
    
    ///  The name of the tag
    public var name: String
    
    public var id: String { name }
    
    /// A description for the tag. CommonMark syntax MAY be used for rich text representation.
    public var description: String?
    
    /// Additional external documentation for this tag.
    public var externalDocs: ExternalDocumentationObject?
    
    public init(name: String, description: String? = nil, externalDocs: ExternalDocumentationObject? = nil) {
        self.name = name
        self.description = description
        self.externalDocs = externalDocs
    }
}

extension TagObject: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.init(name: value)
    }
}
