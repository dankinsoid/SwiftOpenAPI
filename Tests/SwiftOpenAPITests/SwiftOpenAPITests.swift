import Foundation
import XCTest
@testable import SwiftOpenAPI

final class SwiftOpenAPITests: XCTestCase {
    
    final func testEncoding() async throws {
        let file = try Mocks.petsSwagger.getData()
        let decoder = JSONDecoder()
        let _ = try decoder.decode(OpenAPIObject.self, from: file)
    }
}
