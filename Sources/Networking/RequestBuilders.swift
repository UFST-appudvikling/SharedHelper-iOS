//
//  File.swift
//
//
//  Created by Nicolai Dam on 12/06/2023.
//

import Foundation

/// Request builder
/// - Parameters:
///   - url: url + path to hit
///   - parameters: url query params
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
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(UUID().uuidString, forHTTPHeaderField: "x-request-id")
    request.setValue("iOS", forHTTPHeaderField: "x-platform")
    if let appVersion {
        request.setValue(appVersion, forHTTPHeaderField: "x-version")
    }
    if !headers.isEmpty {
        var headerFields = request.allHTTPHeaderFields ?? [:]
        headerFields.merge(headers, uniquingKeysWith: { $1 })
        request.allHTTPHeaderFields = headerFields
    }
    return request
}

/// Request for posting
/// - Parameters:
///   - url: url + path to hit
///   - requestBody: the body to be encoded to json
///   - encoder: supply custom encoder if needed
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
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = try! encoder.encode(requestBody)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(UUID().uuidString, forHTTPHeaderField: "x-request-id")
    request.setValue("iOS", forHTTPHeaderField: "x-platform")
    if let appVersion {
        request.setValue(appVersion, forHTTPHeaderField: "x-version")
    }
    if !headers.isEmpty {
        var headerFields = request.allHTTPHeaderFields ?? [:]
        headerFields.merge(headers, uniquingKeysWith: { $1 })
        request.allHTTPHeaderFields = headerFields
    } 
    return request
}

/// Request for deleting
/// - Parameters:
///   - url: url + path to hit
///   - requestBody: the body to be encoded to json
///   - encoder: supply custom encoder if needed
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
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    request.httpBody = try! encoder.encode(requestBody)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(UUID().uuidString, forHTTPHeaderField: "x-request-id")
    request.setValue("iOS", forHTTPHeaderField: "x-platform")
    if let appVersion {
        request.setValue(appVersion, forHTTPHeaderField: "x-version")
    }
    if !headers.isEmpty {
        var headerFields = request.allHTTPHeaderFields ?? [:]
        headerFields.merge(headers, uniquingKeysWith: { $1 })
        request.allHTTPHeaderFields = headerFields
    }
    return request
}

/// Request for updating
/// - Parameters:
///   - url: url + path to hit
///   - requestBody: the body to be encoded to json
///   - encoder: supply custom encoder if needed
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
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.httpBody = try! encoder.encode(requestBody)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue(UUID().uuidString, forHTTPHeaderField: "x-request-id")
    request.setValue("iOS", forHTTPHeaderField: "x-platform")
    if !headers.isEmpty {
        var headerFields = request.allHTTPHeaderFields ?? [:]
        headerFields.merge(headers, uniquingKeysWith: { $1 })
        request.allHTTPHeaderFields = headerFields
    }
    return request
}
