import Foundation
@testable import SwiftOpenAPI

let petsSwagger = OpenAPIObject(
	openapi: "3.0.2",
	info: InfoObject(
		title: "Swagger Petstore - OpenAPI 3.0",
		description: """
		This is a sample Pet Store Server based on the OpenAPI 3.0 specification.  You can find out more about
		Swagger at [http://swagger.io](http://swagger.io). In the third iteration of the pet store, we've switched to the design first approach!
		You can now help us improve the API whether it's by making changes to the definition itself or to the code.
		That way, with time, we can improve the API in general, and expose some of the new features in OAS3.
		Some useful links:
		- [The Pet Store repository](https://github.com/swagger-api/swagger-petstore)
		- [The source API definition for the Pet Store](https://github.com/swagger-api/swagger-petstore/blob/master/src/main/resources/openapi.yaml)
		""",
		termsOfService: URL(string: "http://swagger.io/terms/"),
		contact: ContactObject(
			email: "apiteam@swagger.io"
		),
		license: LicenseObject(
			name: "Apache 2.0",
			url: URL(string: "http://www.apache.org/licenses/LICENSE-2.0.html")
		),
		version: "1.0.17"
	),
	servers: ["/api/v3"],
	paths: [
		"/pet/findByStatus": .get(
			OperationObject(
				tags: ["pet"],
				summary: "Finds Pets by status",
				description: "Multiple status values can be provided with comma separated strings",
				operationId: "findPetsByStatus",
				parameters: [
					.value(
						ParameterObject(
							name: "status",
							in: .query,
							description: "Status values that need to be considered for filter",
							required: false,
							explode: true,
							schema: .enum(
								of: .string,
								allCases: [
									"available",
									"pending",
									"sold",
								]
							)
						)
					),
				],
				responses: [
					400: "Invalid status value",
					200: .value(
						ResponseObject(
							description: "successful operation",
							content: [
								.application(.json): MediaTypeObject(
									schema: .array(of: .ref(components: \.schemas, "Pet"))
								),
								.application(.xml): MediaTypeObject(
									schema: .array(of: .ref(components: \.schemas, "Pet"))
								),
							]
						)
					),
				],
				security: [
					SecurityRequirementObject(
						name: "petstore_auth",
						values: [
							"write:pets",
							"read:pets",
						]
					),
				]
			)
		),
		"/pet/findByTags": .get(
			OperationObject(
				tags: ["pet"],
				summary: "Finds Pets by tags",
				description: "Multiple tags can be provided with comma separated strings. Use tag1, tag2, tag3 for testing.",
				operationId: "findPetsByTags",
				parameters: [
					.value(
						ParameterObject(
							name: "tags",
							in: .query,
							description: "Tags to filter by",
							required: false,
							explode: true,
							schema: .array(of: .string)
						)
					),
				],
				responses: [
					400: "Invalid tag value",
					200: .value(
						ResponseObject(
							description: "successful operation",
							content: [
								.application(.json): MediaTypeObject(
									schema: .array(of: .ref(components: \.schemas, "Pet"))
								),
								.application(.xml): MediaTypeObject(
									schema: .array(of: .ref(components: \.schemas, "Pet"))
								),
							]
						)),
				],
				security: [
					SecurityRequirementObject(
						name: "petstore_auth",
						values: [
							"write:pets",
							"read:pets",
						]
					),
				]
			)
		),
		"/pet/{petId}/uploadImage": .post(
			OperationObject(
				tags: ["pet"],
				summary: "uploads an image",
				description: "",
				operationId: "uploadFile",
				parameters: [
					.value(
						ParameterObject(
							name: "petId",
							in: .path,
							description: "ID of pet to update",
							required: true,
							schema: .integer
						)
					),
					.value(
						ParameterObject(
							name: "additionalMetadata",
							in: .query,
							description: "Additional Metadata",
							required: false,
							schema: .string
						)
					),
				],
				requestBody: .value(RequestBodyObject(
					content: [
						.application(.octetStream): MediaTypeObject(
							schema: .string(.binary)
						),
					]
				)),
				responses: [
					200: .value(
						ResponseObject(
							description: "successful operation",
							content: [
								.application(.json): MediaTypeObject(
									schema: .ref(components: \.schemas, "ApiResponse")
								),
							]
						)
					),
				],
				security: [
					SecurityRequirementObject(
						name: "petstore_auth",
						values: [
							"write:pets",
							"read:pets",
						]
					),
				]
			)
		),
		"/pet/{petId}": [
			.delete: OperationObject(
				tags: ["pet"],
				summary: "Deletes a pet",
				description: "",
				operationId: "deletePet",
				parameters: [
					.value(
						ParameterObject(
							name: "api_key",
							in: .header,
							description: "",
							required: false,
							schema: .string
						)),
					.value(
						ParameterObject(
							name: "petId",
							in: .path,
							description: "Pet id to delete",
							required: true,
							schema: .integer
						)),
				],
				responses: [
					400: "Invalid pet value",
				],
				security: [
					SecurityRequirementObject(
						name: "petstore_auth",
						values: [
							"write:pets",
							"read:pets",
						]
					),
				]
			),
			.get: OperationObject(
				tags: ["pet"],
				summary: "Find pet by ID",
				description: "Returns a single pet",
				operationId: "getPetById",
				parameters: [
					.value(ParameterObject(
						name: "petId",
						in: .path,
						description: "ID of pet to return",
						required: true,
						schema: .integer
					)),
				],
				responses: [
					400: "Invalid ID supplied",
					404: "Pet not found",
					200: .value(ResponseObject(
						description: "successful operation",
						content: [
							.application(.json): MediaTypeObject(
								schema: .ref(components: \.schemas, "Pet")
							),
							.application(.xml): MediaTypeObject(
								schema: .ref(components: \.schemas, "Pet")
							),
						]
					)),
				],
				security: [
					"api_key",
					SecurityRequirementObject(
						name: "petstore_auth",
						values: [
							"write:pets",
							"read:pets",
						]
					),
				]
			),
			.post: OperationObject(
				tags: ["pet"],
				summary: "Updates a pet in the store with form data",
				description: "",
				operationId: "updatePetWithForm",
				parameters: [
					.value(ParameterObject(
						name: "petId",
						in: .path,
						description: "ID of pet that needs to be updated",
						required: true,
						schema: .integer
					)),
					.value(ParameterObject(
						name: "name",
						in: .query,
						description: "Name of pet that needs to be updated",
						schema: .string
					)),
					.value(ParameterObject(
						name: "status",
						in: .query,
						description: "Status of pet that needs to be updated",
						schema: .string
					)),
				],
				responses: [
					400: "Invalid input",
				],
				security: [
					SecurityRequirementObject(
						name: "petstore_auth",
						values: [
							"write:pets",
							"read:pets",
						]
					),
				]
			),
		],
		"/pet": [
			.post: OperationObject(
				tags: ["pet"],
				summary: "Add a new pet to the store",
				description: "Add a new pet to the store",
				operationId: "addPet",
				requestBody: .value(RequestBodyObject(
					description: "Create a new pet in the store",
					content: [
						.application(.json): MediaTypeObject(
							schema: .ref(components: \.schemas, "Pet")
						),
						.application(.xml): MediaTypeObject(
							schema: .ref(components: \.schemas, "Pet")
						),
						.application(.urlEncoded): MediaTypeObject(
							schema: .ref(components: \.schemas, "Pet")
						),
					],
					required: true
				)),
				responses: [
					400: "Invalid input",
					200: .value(ResponseObject(
						description: "Successful operation",
						content: [
							.application(.json): MediaTypeObject(
								schema: .ref(components: \.schemas, "Pet")
							),
							.application(.xml): MediaTypeObject(
								schema: .ref(components: \.schemas, "Pet")
							),
						]
					)),
				],
				security: [
					SecurityRequirementObject(
						name: "petstore_auth",
						values: [
							"write:pets",
							"read:pets",
						]
					),
				]
			),
			.put: OperationObject(
				tags: ["pet"],
				summary: "Update an existing pet",
				description: "Update an existing pet by Id",
				operationId: "updatePet",
				requestBody: .value(RequestBodyObject(
					description: "Update an existent pet in the store",
					content: [
						.application(.json): MediaTypeObject(
							schema: .ref(components: \.schemas, "Pet")
						),
						.application(.xml): MediaTypeObject(
							schema: .ref(components: \.schemas, "Pet")
						),
						.application(.urlEncoded): MediaTypeObject(
							schema: .ref(components: \.schemas, "Pet")
						),
					],
					required: true
				)),
				responses: [
					400: "Invalid ID supplied",
					404: "Pet not found",
					405: "Validation exception",
					200: .value(ResponseObject(
						description: "Successful operation",
						content: [
							.application(.json): MediaTypeObject(
								schema: .ref(components: \.schemas, "Pet")
							),
							.application(.xml): MediaTypeObject(
								schema: .ref(components: \.schemas, "Pet")
							),
						]
					)
					),
				],
				security: [
					SecurityRequirementObject(
						name: "petstore_auth",
						values: [
							"write:pets",
							"read:pets",
						]
					),
				]
			),
		],
		"/store/inventory": .get(
			OperationObject(
				tags: ["store"],
				summary: "Returns pet inventories by status",
				description: "Returns a map of status codes to quantities",
				operationId: "getInventory",
				responses: [
					200: .value(ResponseObject(
						description: "successful operation",
						content: [
							.application(.json): MediaTypeObject(
								schema: .dictionary(of: .integer(.int32))
							),
						]
					)),
				],
				security: ["api_key"]
			)),
		"/store/order/{orderId}": [
			.delete: OperationObject(
				tags: ["store"],
				summary: "Delete purchase order by ID",
				description: "For valid response try integer IDs with value < 1000. Anything above 1000 or nonintegers will generate API errors",
				operationId: "deleteOrder",
				parameters: [
					.value(ParameterObject(
						name: "orderId",
						in: .path,
						description: "ID of the order that needs to be deleted",
						required: true,
						schema: .integer
					)),
				],
				responses: [
					400: "Invalid ID supplied",
					404: "Order not found",
				]
			),
			.get: OperationObject(
				tags: ["store"],
				summary: "Find purchase order by ID",
				description: "For valid response try integer IDs with value <= 5 or > 10. Other values will generate exceptions.",
				operationId: "getOrderById",
				parameters: [
					.value(ParameterObject(
						name: "orderId",
						in: .path,
						description: "ID of order that needs to be fetched",
						required: true,
						schema: .integer
					)),
				],
				responses: [
					400: "Invalid ID supplied",
					404: "Order not found",
					200: .value(ResponseObject(
						description: "successful operation",
						content: [
							.application(.json): MediaTypeObject(
								schema: .ref(components: \.schemas, "Order")
							),
							.application(.xml): MediaTypeObject(
								schema: .ref(components: \.schemas, "Order")
							),
						]
					)),
				]
			),
		],
		"/store/order": .post(
			OperationObject(
				tags: ["store"],
				summary: "Place an order for a pet",
				description: "Place a new order in the store",
				operationId: "placeOrder",
				requestBody: [
					.application(.json): MediaTypeObject(
						schema: .ref(components: \.schemas, "Order")
					),
					.application(.xml): MediaTypeObject(
						schema: .ref(components: \.schemas, "Order")
					),
					.application(.urlEncoded): MediaTypeObject(
						schema: .ref(components: \.schemas, "Order")
					),
				],
				responses: [
					400: "Invalid input",
					200: .value(ResponseObject(
						description: "successful operation",
						content: [
							.application(.json): MediaTypeObject(
								schema: .ref(components: \.schemas, "Order")
							),
						]
					)),
				]
			)
		),
		"/user/createWithList": [
			.post: OperationObject(
				tags: ["user"],
				summary: "Creates list of users with given input array",
				description: "Creates list of users with given input array",
				operationId: "createUsersWithListInput",
				requestBody: .value(RequestBodyObject(
					content: [
						.application(.json): MediaTypeObject(
							schema: .ref(components: \.schema, "User")
						),
					]
				)),
				responses: [
					.default: "successful operation",
					200: .value(ResponseObject(
						description: "Successful operation",
						content: [
							.application(.json): MediaTypeObject(
								schema: .ref(components: \.schemas, "User")
							),
							.application(.xml): MediaTypeObject(
								schema: .ref(components: \.schemas, "User")
							),
						]
					)),
				]
			),
		],
		"/user/login": .get(
			OperationObject(
				tags: ["user"],
				summary: "Logs user into the system",
				description: "",
				operationId: "loginUser",
				parameters: [
					.value(ParameterObject(
						name: "username",
						in: .query,
						description: "The user name for login",
						required: false,
						schema: .string
					)),
					.value(ParameterObject(
						name: "password",
						in: .query,
						description: "The password for login in clear text",
						required: false,
						schema: .string
					)),
				],
				responses: [
					400: "Invalid username/password supplied",
					200: .value(ResponseObject(
						description: "successful operation",
						headers: [
							"X-Expires-After": .value(
								HeaderObject(
									description: "date in UTC when token expires",
									schema: .dateTime
								)
							),
							"X-Rate-Limit": .value(
								HeaderObject(
									description: "calls per hour allowed by the user",
									schema: .integer(.int32)
								)
							),
						],
						content: [
							.application(.json): MediaTypeObject(
								schema: .string
							),
							.application(.xml): MediaTypeObject(
								schema: .string
							),
						]
					)),
				]
			)
		),
		"/user/logout": .get(
			OperationObject(
				tags: ["user"],
				summary: "Logs out current logged in user session",
				description: "",
				operationId: "logoutUser",
				parameters: [],
				responses: [.default: "successful operation"]
			)
		),
		"/user/{username}": [
			.delete: OperationObject(
				tags: ["user"],
				summary: "Delete user",
				description: "This can only be done by the logged in user.",
				operationId: "deleteUser",
				parameters: [
					.value(ParameterObject(
						name: "username",
						in: .path,
						description: "The name that needs to be deleted",
						required: true,
						schema: .string
					)),
				],
				responses: [
					400: "Invalid username supplied",
					404: "User not found",
				]
			),
			.get: OperationObject(
				tags: ["user"],
				summary: "Get user by user name",
				description: "",
				operationId: "getUserByName",
				parameters: [
					.value(ParameterObject(
						name: "username",
						in: .path,
						description: "The name that needs to be fetched. Use user1 for testing. ",
						required: true,
						schema: .string
					)),
				],
				responses: [
					400: "Invalid username supplied",
					404: "User not found",
					200: .value(ResponseObject(
						description: "successful operation",
						content: [
							.application(.json): MediaTypeObject(
								schema: .ref(components: \.schemas, "User")
							),
							.application(.xml): MediaTypeObject(
								schema: .ref(components: \.schemas, "User")
							),
						]
					)),
				]
			),
			.put: OperationObject(
				tags: [
					"user",
				],
				summary: "Update user",
				description: "This can only be done by the logged in user.",
				operationId: "updateUser",
				parameters: [
					.value(ParameterObject(
						name: "username",
						in: .path,
						description: "name that need to be deleted",
						required: true,
						schema: .string
					)),
				],
				requestBody: .value(RequestBodyObject(
					description: "Update an existent user in the store",
					content: [
						.application(.json): MediaTypeObject(
							schema: .ref(components: \.schemas, "User")
						),
						.application(.urlEncoded): MediaTypeObject(
							schema: .ref(components: \.schemas, "User")
						),
						.application(.xml): MediaTypeObject(
							schema: .ref(components: \.schemas, "User")
						),
					]
				)),
				responses: [.default: "successful operation"]
			),
		],
		"/user": .post(
			OperationObject(
				tags: ["user"],
				summary: "Create user",
				description: "This can only be done by the logged in user.",
				operationId: "createUser",
				requestBody: .value(RequestBodyObject(
					description: "Created user object",
					content: [
						.application(.json): MediaTypeObject(
							schema: .ref(components: \.schemas, "User")
						),
						.application(.urlEncoded): MediaTypeObject(
							schema: .ref(components: \.schemas, "User")
						),
						.application(.xml): MediaTypeObject(
							schema: .ref(components: \.schemas, "User")
						),
					]
				)),
				responses: [
					.default: .value(ResponseObject(
						description: "successful operation",
						content: [
							.application(.json): MediaTypeObject(
								schema: .ref(components: \.schemas, "User")
							),
							.application(.xml): MediaTypeObject(
								schema: .ref(components: \.schemas, "User")
							),
						]
					)),
				]
			)
		),
	],
	components: ComponentsObject(
		schemas: [
			"Address": .object(
				[
					"city": .value(SchemaObject(
						example: "Palo Alto",
						schema: .string
					)),
					"state": .value(SchemaObject(
						example: "CA",
						schema: .string
					)),
					"street": .value(SchemaObject(
						example: "437 Lytton",
						schema: .string
					)),
					"zip": .value(SchemaObject(
						example: "94301",
						schema: .string
					)),
				],
				xml: XMLObject(name: "address")
			),
			"ApiResponse": .object(
				[
					"code": .integer(.int32),
					"message": .string,
					"type": .string,
				],
				xml: XMLObject(name: "##default")
			),
			"Category": .object(
				[
					"id": .value(SchemaObject(
						example: 1,
						schema: .integer
					)),
					"name": .value(SchemaObject(
						example: "Dogs",
						schema: .string
					)),
				],
				xml: XMLObject(name: "category")
			),
			"Customer": .object(
				[
					"address": .ref(components: \.schema, "Address"),
					"id": .value(SchemaObject(
						example: 100_000,
						schema: .integer
					)),
					"username": .value(SchemaObject(
						example: "fehguy",
						schema: .string
					)),
				],
				xml: XMLObject(name: "customer")
			),
			"Order": .object(
				[
					"complete": .boolean,
					"id": .value(SchemaObject(
						example: 10,
						schema: .integer
					)),
					"petId": .value(SchemaObject(
						example: 198_772,
						schema: .integer
					)),
					"quantity": .value(SchemaObject(
						example: 7,
						schema: .integer(.int32)
					)),
					"shipDate": .dateTime,
					"status": .value(SchemaObject(
						description: "Order Status",
						example: "approved",
						schema: .enum(
							of: .string,
							allCases: [
								"placed",
								"approved",
								"delivered",
							]
						)
					)),
				],
				xml: XMLObject(name: "order")
			),
			"Pet": .value(SchemaObject(
				schema: .object(
					[
						"category": .ref(components: \.schemas, "Category"),
						"id": .value(SchemaObject(
							example: 10,
							schema: .integer
						)),
						"name": .value(SchemaObject(
							example: "doggie",
							schema: .string
						)),
						"photoUrls": .array(of: .string),
						"status": .value(SchemaObject(
							description: "pet status in the store",
							schema: .enum(
								of: .string,
								allCases: [
									"available",
									"pending",
									"sold",
								]
							)
						)),
						"tags": .array(of: .ref(components: \.schemas, "Tag")),
					],
					required: [
						"name",
						"photoUrls",
					],
					xml: XMLObject(name: "pet")
				),
				specificationExtensions: ["x-test": "test"]
			)),
			"Tag": .object(
				[
					"id": .integer,
					"name": .string,
				],
				xml: XMLObject(name: "tag")
			),
			"User": .object(
				[
					"email": .value(SchemaObject(
						example: "john@email.com",
						schema: .string
					)),
					"firstName": .value(SchemaObject(
						example: "John",
						schema: .string
					)),
					"id": .value(SchemaObject(
						example: 10,
						schema: .integer
					)),
					"lastName": .value(SchemaObject(
						example: "James",
						schema: .string
					)),
					"password": .value(SchemaObject(
						example: "12345",
						schema: .string
					)),
					"phone": .value(SchemaObject(
						example: "12345",
						schema: .string
					)),
					"userStatus": .value(SchemaObject(
						description: "User Status",
						example: 1,
						schema: .integer(.int32)
					)),
					"username": .value(SchemaObject(
						example: "theUser",
						schema: .string
					)),
				],
				xml: XMLObject(name: "user")
			),
		],
		requestBodies: [
			"Pet": .value(RequestBodyObject(
				description: "Pet object that needs to be added to the store",
				content: [
					.application(.json): MediaTypeObject(
						schema: .ref(components: \.schemas, "Pet")
					),
					.application(.xml): MediaTypeObject(
						schema: .ref(components: \.schemas, "Pet")
					),
				]
			)),
			"UserArray": .value(RequestBodyObject(
				description: "List of user object",
				content: [
					.application(.json): MediaTypeObject(
						schema: .ref(components: \.schema, "User")
					),
				]
			)),
		],
		securitySchemes: [
			"api_key": .apiKey(name: "api_key"),
			"petstore_auth": .oauth2(
				.implicit(authorizationUrl: "https://petstore3.swagger.io/oauth/authorize"),
				scopes: [
					"read:pets": "read your pets",
					"write:pets": "modify pets in your account",
				]
			),
		]
	),
	tags: [
		TagObject(
			name: "pet",
			description: "Everything about your Pets",
			externalDocs: ExternalDocumentationObject(
				description: "Find out more",
				url: URL(string: "http://swagger.io")
			)
		),
		TagObject(
			name: "store",
			description: "Access to Petstore orders",
			externalDocs: ExternalDocumentationObject(
				description: "Find out more about our store",
				url: URL(string: "http://swagger.io")
			)
		),
		TagObject(
			name: "user",
			description: "Operations about user"
		),
	],
	externalDocs: ExternalDocumentationObject(
		description: "Find out more about Swagger",
		url: URL(string: "http://swagger.io")
	)
)
