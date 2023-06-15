import XCTest
@testable import Networking

class NetworkingTests: XCTestCase {

    func testMakeGetNoParams() throws {
        let req = makeGetRequest(url: URL.init(string: "https://test.dk")!)
        XCTAssertEqual(req.url, URL.init(string: "https://test.dk"))
        XCTAssertTrue(req.value(forHTTPHeaderField: "x-platform")!.contains("iOS"))
        XCTAssertNotNil(req.value(forHTTPHeaderField: "x-version")!)
        XCTAssertNotNil(req.value(forHTTPHeaderField: "x-request-id")!)
    }

    func testMakeGetWithParams() throws {
        let params: [String: Any] = [
            "int": 1,
            "double": 1.0
        ]

        let authHeader: [String: String] = ["Authorization": "Some token" ]

        let req = makeGetRequest(url: URL.init(string: "https://test.dk")!, parameters: params, headers: authHeader)
        XCTAssertEqual(req.url?.host, "test.dk")
        XCTAssertEqual(req.httpMethod, "GET")
        XCTAssertTrue(req.url!.query!.contains("int=1"))
        XCTAssertTrue(req.url!.query!.contains("double=1.0"))
        XCTAssertTrue(req.value(forHTTPHeaderField: authHeader.keys.first!)!.contains(authHeader.values.first!))
        XCTAssertTrue(req.value(forHTTPHeaderField: "x-platform")!.contains("iOS"))
        XCTAssertNotNil(req.value(forHTTPHeaderField: "x-version")!)
        XCTAssertNotNil(req.value(forHTTPHeaderField: "x-request-id")!)
    }

    func testMakePost() throws {
        struct Vehicle: Encodable {
            var id: Int
            var name: String
        }
        let encoder = JSONEncoder()
        let mercedes = Vehicle(id: 1, name: "Mercedes 220d")
        let resultBody = try encoder.encode(mercedes)
        let authHeader: [String: String] = ["Authorization": "Some token" ]
        let req = makePostRequest(url: URL.init(string: "https://test.dk")!, requestBody: mercedes, encoder: encoder, headers: authHeader)
        XCTAssertEqual(req.httpBody, resultBody)
        XCTAssertEqual(req.httpMethod, "POST")
        XCTAssertTrue(req.value(forHTTPHeaderField: authHeader.keys.first!)!.contains(authHeader.values.first!))
        XCTAssertTrue(req.value(forHTTPHeaderField: "x-platform")!.contains("iOS"))
        XCTAssertNotNil(req.value(forHTTPHeaderField: "x-version")!)
        XCTAssertNotNil(req.value(forHTTPHeaderField: "x-request-id")!)
    }
}
