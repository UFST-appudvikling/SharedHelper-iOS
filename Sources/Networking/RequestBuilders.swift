//
//  File.swift
//
//
//  Created by Nicolai Dam on 12/06/2023.
//

import Foundation

let appIDKey = "appID"

/// Request for getting
/// Per default a request id, app version platform is in the header for better logging on the backend
/// - Parameters:
///   - url: url + path to hit
///   - parameters: url query params
///   - headers: extra heades
/// - Returns: Request
///

public func makeGetRequest(
    url: URL,
    parameters: [String: Any] = [:],
    headers: [String: String] = [:]
) -> URLRequest {
    var request: URLRequest
    if parameters.isEmpty {
        request = URLRequest(url: url)
    } else {
        let items: [URLQueryItem] = parameters.map {
            URLQueryItem(name: $0.key, value: "\($0.value)")
        }
        var comps = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        comps.queryItems = items

        let escapedPlusChar = comps.url!.absoluteString.replacingOccurrences(of: "+", with: "%2B")
        request = .init(url: URL(string: escapedPlusChar)!)
    }
    var requestWithDefaultHeaders = request.applyDefaultHeaders(appID: RequestBuilder.getAppID())
    requestWithDefaultHeaders.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if !headers.isEmpty {
        var headerFields = requestWithDefaultHeaders.allHTTPHeaderFields ?? [:]
        headerFields.merge(headers, uniquingKeysWith: { $1 })
        requestWithDefaultHeaders.allHTTPHeaderFields = headerFields
    }
    return requestWithDefaultHeaders
}

/// Request for posting
/// Per default a request id, app version platform is in the header for better logging on the backend
/// - Parameters:
///   - url: url + path to hit
///   - requestBody: the body to be encoded to json
///   - encoder: supply custom encoder if needed
///   - headers: extra heades
/// - Returns: Request
public func makePostRequest<Input: Encodable>(
    url: URL,
    requestBody: Input,
    encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }(),
    headers: [String: String] = [:]
) -> URLRequest {
    var request = URLRequest(url: url).applyDefaultHeaders(appID: RequestBuilder.getAppID())
    request.httpMethod = "POST"
    request.httpBody = try! encoder.encode(requestBody)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if !headers.isEmpty {
        var headerFields = request.allHTTPHeaderFields ?? [:]
        headerFields.merge(headers, uniquingKeysWith: { $1 })
        request.allHTTPHeaderFields = headerFields
    } 
    return request
}

/// Request for deleting
/// Per default a request id, app version platform is in the header for better logging on the backend
/// - Parameters:
///   - url: url + path to hit
///   - requestBody: the body to be encoded to json
///   - encoder: supply custom encoder if needed
///   - headers: extra heades
/// - Returns: Request
public func makeDeleteRequest<Input: Encodable>(
    url: URL,
    requestBody: Input,
    encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }(),
    headers: [String: String] = [:]
) -> URLRequest {
    var request = URLRequest(url: url).applyDefaultHeaders(appID: RequestBuilder.getAppID())
    request.httpMethod = "DELETE"
    request.httpBody = try! encoder.encode(requestBody)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if !headers.isEmpty {
        var headerFields = request.allHTTPHeaderFields ?? [:]
        headerFields.merge(headers, uniquingKeysWith: { $1 })
        request.allHTTPHeaderFields = headerFields
    }
    return request
}

/// Request for updating
/// Per default a request id, app version platform is in the header for better logging on the backend
/// - Parameters:
///   - url: url + path to hit
///   - requestBody: the body to be encoded to json
///   - encoder: supply custom encoder if needed
///   - headers: extra heades
/// - Returns: Request
public func makePutRequest<Input: Encodable>(
    url: URL,
    requestBody: Input,
    encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }(),
    headers: [String: String] = [:]
) -> URLRequest {
    var request = URLRequest(url: url).applyDefaultHeaders(appID: RequestBuilder.getAppID())
    request.httpMethod = "PUT"
    request.httpBody = try! encoder.encode(requestBody)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if !headers.isEmpty {
        var headerFields = request.allHTTPHeaderFields ?? [:]
        headerFields.merge(headers, uniquingKeysWith: { $1 })
        request.allHTTPHeaderFields = headerFields
    }
    return request
}

private extension URLRequest {
    func applyDefaultHeaders(appID: String) -> URLRequest {
        var copy = self
        var headers = self.allHTTPHeaderFields ?? [:]
        headers["X-UFST-Client-ID"] = appID
        headers["X-UFST-Client-Request-ID"] = UUID().uuidString
        headers["X-UFST-Client-Platform"] = "iOS"
        headers["X-UFST-Client-Version"] = Bundle.main.versionNumber
        copy.allHTTPHeaderFields = headers
        return copy
    }
}

actor RequestBuilder {
    
    /// If there already exists a appID this will be returned, otherwise there is created a new uiid and saved locally
    public static func getAppID(
        generateUIID: () -> UUID = { UUID() },
        saveAppID: (_ value: String) -> Void = { UserDefaults.standard.set(appIDKey, forKey: $0) },
        getAppID: (_ key: String) -> String? = { UserDefaults.standard.string(forKey: $0) }
    ) -> String {
        guard let existingAppID = getAppID(appIDKey) else {
            let value = generateUIID().uuidString
            saveAppID(value)
            return value
        }
        return existingAppID
    }
}

private extension Bundle {
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    }
}
