import XCTest
@testable import Networking

class NetworkingTests: XCTestCase {

    func testMakeGetNoParams() throws {
        let req = makeGetRequest(url: URL.init(string: "https://test.dk")!)
        XCTAssertEqual(req.url, URL.init(string: "https://test.dk"))
        XCTAssertTrue(req.value(forHTTPHeaderField: "X-UFST-Platform")!.contains("iOS"))
        XCTAssertNotNil(req.value(forHTTPHeaderField: "X-UFST-App-Version")!)
        XCTAssertNotNil(req.value(forHTTPHeaderField: "X-UFST-Request-ID")!)
        XCTAssertNotNil(req.value(forHTTPHeaderField: "X-UFST-App-ID")!)
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
        XCTAssertTrue(req.value(forHTTPHeaderField: "X-UFST-Platform")!.contains("iOS"))
        XCTAssertNotNil(req.value(forHTTPHeaderField: "X-UFST-App-Version")!)
        XCTAssertNotNil(req.value(forHTTPHeaderField: "X-UFST-Request-ID")!)
        XCTAssertNotNil(req.value(forHTTPHeaderField: "X-UFST-App-ID")!)
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
        XCTAssertTrue(req.value(forHTTPHeaderField: "X-UFST-Platform")!.contains("iOS"))
        XCTAssertNotNil(req.value(forHTTPHeaderField: "X-UFST-App-Version")!)
        XCTAssertNotNil(req.value(forHTTPHeaderField: "X-UFST-Request-id")!)
        XCTAssertNotNil(req.value(forHTTPHeaderField: "X-UFST-App-ID")!)
    }
    
    func test_getAppIDFromUserDefaults_Empty() {
        
        let uuid = UUID()
        var savedValuesArray: [String] = []
        var key: String?
        
        let result = getAppIDFromUserDefaults(
            generateUIID: { uuid },
            saveAppIDInUserDefaults: { savedValuesArray.append($0) },
            getAppID: {
                key = $0
                return nil
            }
        )
        
        XCTAssertEqual(uuid.uuidString, result)
        XCTAssertEqual(savedValuesArray, [uuid.uuidString])
        XCTAssertEqual(key, "appID")
        
    }
    
    func test_getAppIDFromUserDefaults_ExistingAppID() {
        
        var key: String?
        let savedValue = "savedValue"
        
        let result = getAppIDFromUserDefaults(
            generateUIID: { fatalError() },
            saveAppIDInUserDefaults: { _ in fatalError() },
            getAppID: {
                key = $0
                return savedValue
            }
        )
        
        XCTAssertEqual(savedValue, result)
        XCTAssertEqual(key, "appID")
    }
}
