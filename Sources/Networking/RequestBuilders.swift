//
//  File.swift
//
//
//  Created by Nicolai Dam on 12/06/2023.
//

import Foundation

/// Request for getting
/// Per default a uiid and platform is in the header and if appVersion is there it will also be in the header
/// - Parameters:
///   - url: url + path to hit
///   - parameters: url query params
///   - headers: extra heades
/// - Returns: Request

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
    var requestWithDefaultHeaders = request.applyDefaultHeaders()
    requestWithDefaultHeaders.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if !headers.isEmpty {
        var headerFields = requestWithDefaultHeaders.allHTTPHeaderFields ?? [:]
        headerFields.merge(headers, uniquingKeysWith: { $1 })
        requestWithDefaultHeaders.allHTTPHeaderFields = headerFields
    }
    return requestWithDefaultHeaders
}

/// Request for posting
/// Per default a uiid and platform is in the header and if appVersion is there it will also be in the header
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
    var request = URLRequest(url: url).applyDefaultHeaders()
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
/// Per default a uiid and platform is in the header and if appVersion is there it will also be in the header
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
    var request = URLRequest(url: url).applyDefaultHeaders()
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
/// Per default a uiid and platform is in the header and if appVersion is there it will also be in the header
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
    var request = URLRequest(url: url).applyDefaultHeaders()
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
    func applyDefaultHeaders() -> URLRequest {
        var copy = self
        var headers = self.allHTTPHeaderFields ?? [:]
        headers["x-request-id"] = UUID().uuidString
        headers["x-platform"] = "iOS"
        headers["x-version"] = Bundle.main.versionNumber
        copy.allHTTPHeaderFields = headers
        return copy
    }
}

public extension Bundle {
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    }
}
