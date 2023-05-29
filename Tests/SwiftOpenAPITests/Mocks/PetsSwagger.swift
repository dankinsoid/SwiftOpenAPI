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
								cases: [
									"available",
									"pending",
									"sold",
								]
							)
						)
					),
				],
				responses: [
					.badRequest: "Invalid status value",
					.ok: .value(
						ResponseObject(
							description: "successful operation",
							content: [
								.application(.json): .array(of: .ref(components: \.schemas, "Pet")),
								.application(.xml): .array(of: .ref(components: \.schemas, "Pet")),
							]
						)
					),
				],
				security: [
					SecurityRequirementObject(
						"petstore_auth",
						[
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
								.application(.json): .array(of: .ref(components: \.schemas, "Pet")),
								.application(.xml): .array(of: .ref(components: \.schemas, "Pet")),
							]
						)),
				],
				security: [
					SecurityRequirementObject(
						"petstore_auth",
						[
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
						.application(.octetStream): .string(format: .binary),
					]
				)),
				responses: [
					200: .value(
						ResponseObject(
							description: "successful operation",
							content: [
								.application(.json): .ref(components: \.schemas, "ApiResponse"),
							]
						)
					),
				],
				security: [
					SecurityRequirementObject(
						"petstore_auth",
						[
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
						"petstore_auth",
						[
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
							.application(.json): .ref(components: \.schemas, "Pet"),
							.application(.xml): .ref(components: \.schemas, "Pet"),
						]
					)),
				],
				security: [
					"api_key",
					SecurityRequirementObject(
						"petstore_auth",
						[
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
						"petstore_auth",
						[
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
						.application(.json): .ref(components: \.schemas, "Pet"),
						.application(.xml): .ref(components: \.schemas, "Pet"),
						.application(.urlEncoded): .ref(components: \.schemas, "Pet"),
					],
					required: true
				)),
				responses: [
					.badRequest: "Invalid input",
					.ok: .value(ResponseObject(
						description: "Successful operation",
						content: [
							.application(.json): .ref(components: \.schemas, "Pet"),
							.application(.xml): .ref(components: \.schemas, "Pet"),
						]
					)),
				],
				security: [
					SecurityRequirementObject(
						"petstore_auth",
						[
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
						.application(.json): .ref(components: \.schemas, "Pet"),
						.application(.xml): .ref(components: \.schemas, "Pet"),
						.application(.urlEncoded): .ref(components: \.schemas, "Pet"),
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
							.application(.json): .ref(components: \.schemas, "Pet"),
							.application(.xml): .ref(components: \.schemas, "Pet"),
						]
					)
					),
				],
				security: [
					SecurityRequirementObject(
						"petstore_auth",
						[
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
							.application(.json): .dictionary(of: .integer(format: .int32)),
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
					.badRequest: "Invalid ID supplied",
					.notFound: "Order not found",
					.ok: .value(ResponseObject(
						description: "successful operation",
						content: [
							.application(.json): .ref(components: \.schemas, "Order"),
							.application(.xml): .ref(components: \.schemas, "Order"),
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
					.application(.json): .ref(components: \.schemas, "Order"),
					.application(.xml): .ref(components: \.schemas, "Order"),
					.application(.urlEncoded): .ref(components: \.schemas, "Order"),
				],
				responses: [
					400: "Invalid input",
					200: .value(ResponseObject(
						description: "successful operation",
						content: [
							.application(.json): .ref(components: \.schemas, "Order"),
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
						.application(.json): .ref(components: \.schemas, "User"),
					]
				)),
				responses: [
					.default: "successful operation",
					.ok: .value(ResponseObject(
						description: "Successful operation",
						content: [
							.application(.json): .ref(components: \.schemas, "User"),
							.application(.xml): .ref(components: \.schemas, "User"),
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
									schema: .integer(format: .int32)
								)
							),
						],
						content: [
							.application(.json): .string,
							.application(.xml): .string,
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
					.badRequest: "Invalid username supplied",
					.notFound: "User not found",
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
					.notFound: "User not found",
					.ok: .value(ResponseObject(
						description: "successful operation",
						content: [
							.application(.json): .ref(components: \.schemas, "User"),
							.application(.xml): .ref(components: \.schemas, "User"),
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
						.application(.json): .ref(components: \.schemas, "User"),
						.application(.urlEncoded): .ref(components: \.schemas, "User"),
						.application(.xml): .ref(components: \.schemas, "User"),
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
						.application(.json): .ref(components: \.schemas, "User"),
						.application(.urlEncoded): .ref(components: \.schemas, "User"),
						.application(.xml): .ref(components: \.schemas, "User"),
					]
				)),
				responses: [
					.default: .value(ResponseObject(
						description: "successful operation",
						content: [
							.application(.json): .ref(components: \.schemas, "User"),
							.application(.xml): .ref(components: \.schemas, "User"),
						]
					)),
				]
			)
		),
	],
	components: ComponentsObject(
		schemas: [
			"Address": .object(
				properties: [
					"city": .string(example: "Palo Alto"),
					"state": .string(example: "CA"),
					"street": .string(example: "437 Lytton"),
					"zip": .string(example: "94301"),
				],
				xml: XMLObject(name: "address")
			),
			"ApiResponse": .object(
				properties: [
					"code": .integer(format: .int32),
					"message": .string,
					"type": .string,
				],
				xml: XMLObject(name: "##default")
			),
			"Category": .object(
				properties: [
					"id": .integer(example: 1),
					"name": .string(example: "Dogs"),
				],
				xml: XMLObject(name: "category")
			),
			"Customer": .object(
				properties: [
					"address": .ref(components: \.schemas, "Address"),
					"id": .integer(example: 100_000),
					"username": .string(example: "fehguy"),
				],
				xml: XMLObject(name: "customer")
			),
			"Order": .object(
				properties: [
					"complete": .boolean,
					"id": .integer(example: 10),
					"petId": .integer(example: 198_772),
					"quantity": .integer(format: .int32, example: 7),
					"shipDate": .dateTime,
					"status": .enum(
						cases: [
							"placed",
							"approved",
							"delivered",
						],
						description: "Order Status",
						example: "approved"
					),
				],
				xml: XMLObject(name: "order")
			),
			"Pet": .object(
				properties: [
					"category": .ref(components: \.schemas, "Category"),
					"id": .integer(example: 10),
					"name": .string(example: "doggie"),
					"photoUrls": .array(of: .string),
					"status": .enum(
						cases: [
							"available",
							"pending",
							"sold",
						],
						description: "pet status in the store"
					),
					"tags": .array(of: .ref(components: \.schemas, "Tag")),
				],
				required: [
					"name",
					"photoUrls",
				],
				xml: XMLObject(name: "pet")
			),
			"Tag": .object(
				properties: [
					"id": .integer,
					"name": .string,
				],
				xml: XMLObject(name: "tag")
			),
			"User": .object(
				properties: [
					"email": .string(example: "john@email.com"),
					"firstName": .string(example: "John"),
					"id": .integer(example: 10),
					"lastName": .string(example: "James"),
					"password": .string(example: "12345"),
					"phone": .string(example: "12345"),
					"userStatus": .integer(format: .int32, description: "User Status", example: 1),
					"username": .string(example: "theUser"),
				],
				xml: XMLObject(name: "user")
			),
		],
		requestBodies: [
			"Pet": .value(RequestBodyObject(
				description: "Pet object that needs to be added to the store",
				content: [
					.application(.json): .ref(components: \.schemas, "Pet"),
					.application(.xml): .ref(components: \.schemas, "Pet"),
				]
			)),
			"UserArray": .value(RequestBodyObject(
				description: "List of user object",
				content: [
					.application(.json): .ref(components: \.schemas, "User"),
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
