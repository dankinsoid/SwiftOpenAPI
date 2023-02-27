import Foundation

/// Allows configuration of the supported OAuth Flows.
public struct OAuthFlowsObject: Codable, Equatable, SpecificationExtendable {
    
    /// Configuration for the OAuth Implicit flow
    public var implicit: OAuthFlowObject?
    
    /// Configuration for the OAuth Resource Owner Password flow
    public var password: OAuthFlowObject?
    
    /// Configuration for the OAuth Client Credentials flow. Previously called application in OpenAPI 2.0.
    public var clientCredentials: OAuthFlowObject?
                                                  
    /// Configuration for the OAuth Authorization Code flow. Previously called accessCode in OpenAPI 2.0.
    public var authorizationCode: OAuthFlowObject?
    
    public init(implicit: OAuthFlowObject? = nil, password: OAuthFlowObject? = nil, clientCredentials: OAuthFlowObject? = nil, authorizationCode: OAuthFlowObject? = nil) {
        self.implicit = implicit
        self.password = password
        self.clientCredentials = clientCredentials
        self.authorizationCode = authorizationCode
    }
}
