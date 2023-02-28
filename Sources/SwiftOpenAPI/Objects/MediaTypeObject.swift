import Foundation

/// Each Media Type Object provides schema and examples for the media type identified by its key.
public struct MediaTypeObject: Codable, Equatable, SpecificationExtendable {
    
    /// The schema defining the content of the request, response, or parameter.
    public var schema: ReferenceOr<SchemaObject>?
    
    /// Example of the media type.  The example object SHOULD be in the correct format as specified by the media type.  The `example` field is mutually exclusive of the `examples` field.  Furthermore, if referencing a `schema` which contains an example, the `example` value SHALL <em>override</em> the example provided by the schema.
    public var example: AnyValue?
    
    /// Examples of the media type.  Each example object SHOULD  match the media type and specified schema if present.  The `examples` field is mutually exclusive of the `example` field.  Furthermore, if referencing a `schema` which contains an example, the `examples` value SHALL <em>override</em> the example provided by the schema.
    public var examples: [String: ReferenceOr<ExampleObject>]?
    
    /// A map between a property name and its encoding information. The key, being the property name, MUST exist in the schema as a property. The encoding object SHALL only apply to requestBody objects when the media type is multipart or application/x-www-form-urlencoded.
    public var encoding: [String: EncodingObject]?
    
    public init(
        schema: ReferenceOr<SchemaObject>? = nil,
        example: AnyValue? = nil,
        encoding: [String: EncodingObject]? = nil
    ) {
        self.schema = schema
        self.example = example
        self.encoding = encoding
    }
    
    public init(
        schema: ReferenceOr<SchemaObject>? = nil,
        examples: [String: ReferenceOr<ExampleObject>],
        encoding: [String: EncodingObject]? = nil
    ) {
        self.schema = schema
        self.examples = examples
        self.encoding = encoding
    }
}

public extension MediaTypeObject {
    
    static func encode(
        _ value: Encodable,
        schemas: inout [String: ReferenceOr<SchemaObject>]
    ) throws -> MediaTypeObject {
        try MediaTypeObject(
            schema: .encode(value, into: &schemas),
            example: .encode(value)
        )
    }
}
