import Foundation

public struct ResponsesObject: Codable, Equatable, SpecificationExtendable, ExpressibleByDictionary {

	public typealias Value = ReferenceOr<ResponseObject>

	public var value: [Key: Value]
	//public var specificationExtensions: SpecificationExtensions? = nil

	public init(_ value: [Key: Value] = [:]) {
		self.value = value
	}

	public init(dictionaryElements elements: [(Key, Value)]) {
		self.init(
			Dictionary(elements) { _, second in
				second
			}
		)
	}

	public init(from decoder: Decoder) throws {
		value = try decoder.decodeDictionary(of: [Key: Value].self)
	}

	public func encode(to encoder: Encoder) throws {
		try encoder.encodeDictionary(value)
	}

	public subscript(_ key: Key) -> Value? {
		get { value[key] }
		set { value[key] = newValue }
	}
}

public extension ResponsesObject {

	enum Key: Hashable, Codable, Equatable, RawRepresentable, CodingKey, ExpressibleByIntegerLiteral, LosslessStringConvertible {
		
		case code(Int)
		case `default`

		public var rawValue: String {
			switch self {
			case let .code(int):
				return "\(int)"
			case .default:
				return Self.defaultRawValue
			}
		}

		public var stringValue: String { rawValue }
		public var description: String { rawValue }

		public var intValue: Int? {
			if case let .code(int) = self {
				return int
			}
			return nil
		}

		public init?(rawValue: String) {
			if rawValue == Self.defaultRawValue {
				self = .default
			} else if let code = Int(rawValue) {
				self = .code(code)
			} else {
				return nil
			}
		}

		public init?(intValue: Int) {
			self = .code(intValue)
		}

		public init(integerLiteral value: Int) {
			self = .code(value)
		}

		public init?(stringValue: String) {
			self.init(rawValue: stringValue)
		}

		public init?(_ description: String) {
			self.init(rawValue: description)
		}

		public init(from decoder: Decoder) throws {
			let rawValue = try String(from: decoder)
			guard let key = Self(rawValue: rawValue) else {
				throw DecodingError.dataCorrupted(
					DecodingError.Context(
						codingPath: decoder.codingPath,
						debugDescription: "Invalid responses field, expected 'default' or status code, \(rawValue) found"
					)
				)
			}
			self = key
		}

		public func encode(to encoder: Encoder) throws {
			try rawValue.encode(to: encoder)
		}

		private static let defaultRawValue = "default"
	}
}

public extension ResponsesObject.Key {
	
	static let `continue`: ResponsesObject.Key = .code(100)
	static let switchingProtocols: ResponsesObject.Key = .code(101)
	static let processing: ResponsesObject.Key = .code(102)
	
	static let ok: ResponsesObject.Key = .code(200)
	static let created: ResponsesObject.Key = .code(201)
	static let accepted: ResponsesObject.Key = .code(202)
	static let nonAuthoritativeInformation: ResponsesObject.Key = .code(203)
	static let noContent: ResponsesObject.Key = .code(204)
	static let resetContent: ResponsesObject.Key = .code(205)
	static let partialContent: ResponsesObject.Key = .code(206)
	static let multiStatus: ResponsesObject.Key = .code(207)
	static let alreadyReported: ResponsesObject.Key = .code(208)
	static let imUsed: ResponsesObject.Key = .code(226)
	
	static let multipleChoices: ResponsesObject.Key = .code(300)
	static let movedPermanently: ResponsesObject.Key = .code(301)
	static let found: ResponsesObject.Key = .code(302)
	static let seeOther: ResponsesObject.Key = .code(303)
	static let notModified: ResponsesObject.Key = .code(304)
	static let useProxy: ResponsesObject.Key = .code(305)
	static let temporaryRedirect: ResponsesObject.Key = .code(307)
	static let permanentRedirect: ResponsesObject.Key = .code(308)
	
	static let badRequest: ResponsesObject.Key = .code(400)
	static let unauthorized: ResponsesObject.Key = .code(401)
	static let paymentRequired: ResponsesObject.Key = .code(402)
	static let forbidden: ResponsesObject.Key = .code(403)
	static let notFound: ResponsesObject.Key = .code(404)
	static let methodNotAllowed: ResponsesObject.Key = .code(405)
	static let notAcceptable: ResponsesObject.Key = .code(406)
	static let proxyAuthenticationRequired: ResponsesObject.Key = .code(407)
	static let requestTimeout: ResponsesObject.Key = .code(408)
	static let conflict: ResponsesObject.Key = .code(409)
	static let gone: ResponsesObject.Key = .code(410)
	static let lengthRequired: ResponsesObject.Key = .code(411)
	static let preconditionFailed: ResponsesObject.Key = .code(412)
	static let payloadTooLarge: ResponsesObject.Key = .code(413)
	static let uriTooLong: ResponsesObject.Key = .code(414)
	static let unsupportedMediaType: ResponsesObject.Key = .code(415)
	static let rangeNotSatisfiable: ResponsesObject.Key = .code(416)
	static let expectationFailed: ResponsesObject.Key = .code(417)
	static let imATeapot: ResponsesObject.Key = .code(418)
	static let misdirectedRequest: ResponsesObject.Key = .code(421)
	static let unprocessableEntity: ResponsesObject.Key = .code(422)
	static let locked: ResponsesObject.Key = .code(423)
	static let failedDependency: ResponsesObject.Key = .code(424)
	static let upgradeRequired: ResponsesObject.Key = .code(426)
	static let preconditionRequired: ResponsesObject.Key = .code(428)
	static let tooManyRequests: ResponsesObject.Key = .code(429)
	static let requestHeaderFieldsTooLarge: ResponsesObject.Key = .code(431)
	static let unavailableForLegalReasons: ResponsesObject.Key = .code(451)
	
	static let internalServerError: ResponsesObject.Key = .code(500)
	static let notImplemented: ResponsesObject.Key = .code(501)
	static let badGateway: ResponsesObject.Key = .code(502)
	static let serviceUnavailable: ResponsesObject.Key = .code(503)
	static let gatewayTimeout: ResponsesObject.Key = .code(504)
	static let httpVersionNotSupported: ResponsesObject.Key = .code(505)
	static let variantAlsoNegotiates: ResponsesObject.Key = .code(506)
	static let insufficientStorage: ResponsesObject.Key = .code(507)
	static let loopDetected: ResponsesObject.Key = .code(508)
	static let notExtended: ResponsesObject.Key = .code(510)
	static let networkAuthenticationRequired: ResponsesObject.Key = .code(511)
}
