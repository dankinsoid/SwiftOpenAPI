import Foundation
import XCTest
@testable import SwiftOpenAPI

final class SwiftOpenAPITests: XCTestCase {
    
    func testDecoding() async throws {
        let file = try Mocks.petsSwagger.getData()
        let decoder = JSONDecoder()
        let _ = try decoder.decode(OpenAPIObject.self, from: file)
    }
    
    func testSchemeEncoding() throws {
        var references: [String: ReferenceOr<SchemaObject>] = [:]
        try SchemaObject.encode(LoginBody.example, into: &references)
        XCTAssertEqual(
            references,
            [
                "SomeEnum": .value(
                    .enum(.string, allCases: ["first", "second"])
                ),
                "LoginBody": .value(
                    .object(
                        [
                            "username": .value(.primitive(.string)),
                            "password": .value(.primitive(.string)),
                            "tags": .value(.array(.value(.primitive(.string)))),
                            "id": .value(.primitive(.string, format: "uuid")),
                            "enumValue": .ref(components: \.schemas, "SomeEnum"),
                            "comments": .value(
                                .object(nil, required: nil, additionalProperties: .value(.primitive(.string)))
                            )
                        ],
                        required: ["id", "username", "password"]
                    )
                )
            ]
        )
    }
}

func prettyPrint(_ value: some Encodable) throws {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    try print(
        String(
            data: encoder.encode(value),
            encoding: .utf8
        ) ?? ""
    )
}


struct LoginBody: Codable {
    
    var username: String
    var password: String
    var tags: Set<String>?
    var comments: [String: String]?
    var enumValue: SomeEnum?
    var id: UUID
    
    static let example = LoginBody(
        username: "User",
        password: "12345678",
        tags: ["tag"],
        comments: ["Danil": "Comment"],
        enumValue: .first,
        id: UUID()
    )
    
    struct NestedStruct: Codable {
        
        public struct VK: Hashable, Codable {
            
            public var id: Decimal
            public var ids: String?
            public var ownerId: Int?
            public var addHash: String?
            public var trackCode: String?
            public var albumTitle: String?
            
            public init(
                id: Decimal,
                ids: String? = nil,
                ownerId: Int? = nil,
                addHash: String? = nil,
                trackCode: String? = nil,
                albumTitle: String? = nil
            ) {
                self.id = id
                self.ids = ids
                self.ownerId = ownerId
                self.addHash = addHash
                self.trackCode = trackCode
                self.albumTitle = albumTitle
            }
            
            public static let example = VK(
                id: 1,
                ids: "1_1",
                ownerId: 1,
                addHash: "1",
                trackCode: "1",
                albumTitle: "1"
            )
        }
        
        public struct Apple: Hashable, Codable {
            
            public var iTunesLink: URL?
            public var type: SomeEnum?
            
            public init(
                iTunesLink: URL? = nil,
                type: SomeEnum? = nil
            ) {
                self.iTunesLink = iTunesLink
                self.type = type
            }
            
            public static let example = Apple(
                iTunesLink: nil,
                type: .first
            )
        }
        
        public struct Spotify: Hashable, Codable {
            
            public var uri: String
            public var previewUrl: String?
            public var albumTitle: String?
            
            public init(
                uri: String,
                previewUrl: String? = nil,
                albumTitle: String? = nil
            ) {
                self.uri = uri
                self.previewUrl = previewUrl
                self.albumTitle = albumTitle
            }
            
            public static let example = Spotify(
                uri: "spotify:track:1",
                previewUrl: "https://p.scdn.co/mp3-preview/1",
                albumTitle: "1"
            )
        }
        
        public struct Yandex: Hashable, Codable {
            
            public var albumTitle: String?
            
            public init(albumTitle: String) {
                self.albumTitle = albumTitle
            }
            
            public static let example = Yandex(albumTitle: "1")
        }
        
        public var vk: VK?
        public var am: Apple?
        public var spotify: Spotify?
        public var ym: Yandex?
        
        public init(
            vk: VK? = nil,
            am: Apple? = nil,
            spotify: Spotify? = nil,
            ym: Yandex? = nil
        ) {
            self.vk = vk
            self.am = am
            self.spotify = spotify
            self.ym = ym
        }
        
        public static let example = NestedStruct(
            vk: .example,
            am: .example,
            spotify: .example,
            ym: .example
        )
    }
}

enum SomeEnum: String, Codable, CaseIterable {
    
    case first, second
}
