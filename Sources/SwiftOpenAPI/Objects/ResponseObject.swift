import Foundation

public struct ResponseObject: Codable, Equatable, SpecificationExtendable {
    
    /// A description of the response. CommonMark syntax MAY be used for rich text representation.
    public var description: String
    
    /// Maps a header name to its definition. RFC7230 states header names are case insensitive. If a response header is defined with the name "Content-Type", it SHALL be ignored.
    public var headers: [String: ReferenceOr<HeaderObject>]?
    
    /// A map containing descriptions of potential response payloads. The key is a media type or media type range and the value describes it. For responses that match multiple keys, only the most specific key is applicable. e.g. text/plain overrides text/*
    public var content: [String: MediaTypeObject]?
    
    /// A map of operations links that can be followed from the response. The key of the map is a short name for the link, following the naming constraints of the names for Component Objects.
    public var links: [String: ReferenceOr<LinkObject>]?
    
    
    public init(description: String, headers: [String: ReferenceOr<HeaderObject>]? = nil, content: [String : MediaTypeObject]? = nil, links: [String: ReferenceOr<LinkObject>]? = nil) {
        self.description = description
        self.headers = headers
        self.content = content
        self.links = links
    }
}
