import XCTest
@testable import Networking

class NetworkingTests: XCTestCase {

    func testMakeGetNoParams() throws {
        let appIdentifier = "AppIdentifier"
        let req = makeGetRequest(url: URL.init(string: "https://test.dk")!, appID: appIdentifier)
        XCTAssertEqual(req.url, URL.init(string: "https://test.dk"))
        XCTAssertTrue(req.value(forHTTPHeaderField: "X-Platform")!.contains("iOS"))
        XCTAssertNotNil(req.value(forHTTPHeaderField: "X-App-Version")!)
        XCTAssertNotNil(req.value(forHTTPHeaderField: "X-Request-ID")!)
        XCTAssertTrue(req.value(forHTTPHeaderField: "X-App-ID")!.contains(appIdentifier))
    }

    func testMakeGetWithParams() throws {
        let appIdentifier = "AppIdentifier"
        let params: [String: Any] = [
            "int": 1,
            "double": 1.0
        ]

        let authHeader: [String: String] = ["Authorization": "Some token" ]

        let req = makeGetRequest(url: URL.init(string: "https://test.dk")!, parameters: params, appID: appIdentifier, headers: authHeader)
        XCTAssertEqual(req.url?.host, "test.dk")
        XCTAssertEqual(req.httpMethod, "GET")
        XCTAssertTrue(req.url!.query!.contains("int=1"))
        XCTAssertTrue(req.url!.query!.contains("double=1.0"))
        XCTAssertTrue(req.value(forHTTPHeaderField: authHeader.keys.first!)!.contains(authHeader.values.first!))
        XCTAssertTrue(req.value(forHTTPHeaderField: "X-Platform")!.contains("iOS"))
        XCTAssertNotNil(req.value(forHTTPHeaderField: "X-App-Version")!)
        XCTAssertNotNil(req.value(forHTTPHeaderField: "X-Request-ID")!)
        XCTAssertTrue(req.value(forHTTPHeaderField: "X-App-ID")!.contains(appIdentifier))
    }

    func testMakePost() throws {
        let appIdentifier = "AppIdentifier"
        struct Vehicle: Encodable {
            var id: Int
            var name: String
        }
        let encoder = JSONEncoder()
        let mercedes = Vehicle(id: 1, name: "Mercedes 220d")
        let resultBody = try encoder.encode(mercedes)
        let authHeader: [String: String] = ["Authorization": "Some token" ]
        let req = makePostRequest(url: URL.init(string: "https://test.dk")!, requestBody: mercedes, encoder: encoder, appID: appIdentifier, headers: authHeader)
        XCTAssertEqual(req.httpBody, resultBody)
        XCTAssertEqual(req.httpMethod, "POST")
        XCTAssertTrue(req.value(forHTTPHeaderField: authHeader.keys.first!)!.contains(authHeader.values.first!))
        XCTAssertTrue(req.value(forHTTPHeaderField: "X-Platform")!.contains("iOS"))
        XCTAssertNotNil(req.value(forHTTPHeaderField: "X-App-Version")!)
        XCTAssertNotNil(req.value(forHTTPHeaderField: "X-Request-id")!)
        XCTAssertTrue(req.value(forHTTPHeaderField: "X-App-ID")!.contains(appIdentifier))
    }
}
