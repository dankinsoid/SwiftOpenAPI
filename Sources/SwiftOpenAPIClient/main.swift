import SwiftOpenAPI
import Foundation

/// It's an example struct with doc comment
///
@CollectDocComments
@CollectDefaultValues
struct ExampleStruct: Codable, OpenAPIDescriptable, WithDefaultValues {
    
    /// Some example property
    var someProperty = "Some value"
}

print(ExampleStruct.openAPIDescription)
print(ExampleStruct.defaultValues)
