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
///   - appVersion: App version, for example 1.2.4
/// - Returns: Request

public func makeGetRequest(
    url: URL,
    parameters: [String: Any] = [:],
    headers: [String: String] = [:],
    appVersion: String? = nil
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
    var requestWithDefaultHeaders = request.applyDefaultHeaders(appVersion)
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
///   - appVersion: App version, for example 1.2.4
/// - Returns: Request
public func makePostRequest<Input: Encodable>(
    url: URL,
    requestBody: Input,
    encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }(),
    headers: [String: String] = [:],
    appVersion: String? = nil
) -> URLRequest {
    var request = URLRequest(url: url).applyDefaultHeaders(appVersion)
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
///   - appVersion: App version, for example 1.2.4
/// - Returns: Request
public func makeDeleteRequest<Input: Encodable>(
    url: URL,
    requestBody: Input,
    encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }(),
    headers: [String: String] = [:],
    appVersion: String? = nil
) -> URLRequest {
    var request = URLRequest(url: url).applyDefaultHeaders(appVersion)
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
///   - appVersion: App version, for example 1.2.4
/// - Returns: Request
public func makePutRequest<Input: Encodable>(
    url: URL,
    requestBody: Input,
    encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }(),
    headers: [String: String] = [:],
    appVersion: String? = nil
) -> URLRequest {
    var request = URLRequest(url: url).applyDefaultHeaders(appVersion)
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
    func applyDefaultHeaders(_ appVersion: String?) -> URLRequest {
        var copy = self
        var headers = self.allHTTPHeaderFields ?? [:]
        headers["x-request-id"] = UUID().uuidString
        headers["x-platform"] = "iOS"
        if let appVersion {
            headers["x-version"] = appVersion
        }
        copy.allHTTPHeaderFields = headers
        return copy
    }
}
