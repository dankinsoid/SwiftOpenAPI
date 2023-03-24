import Foundation

public struct OAuthFlowObject: Codable, Equatable, SpecificationExtendable {
	/// The authorization URL to be used for this flow. This MUST be in the form of a URL. The OAuth2 standard requires the use of TLS.
	public var authorizationUrl: String?

	/// The token URL to be used for this flow. This MUST be in the form of a URL. The OAuth2 standard requires the use of TLS.
	public var tokenUrl: String?

	/// The URL to be used for obtaining refresh tokens. This MUST be in the form of a URL. The OAuth2 standard requires the use of TLS.
	public var refreshUrl: String?

	/// The available scopes for the OAuth2 security scheme. A map between the scope name and a short description for it. The map MAY be empty.
	public var scopes: [String: String]?

	public var specificationExtensions: SpecificationExtensions? = nil

	public init(authorizationUrl: String? = nil, tokenUrl: String? = nil, refreshUrl: String? = nil, scopes: [String: String]? = nil) {
		self.authorizationUrl = authorizationUrl
		self.tokenUrl = tokenUrl
		self.refreshUrl = refreshUrl
		self.scopes = scopes
	}
}
