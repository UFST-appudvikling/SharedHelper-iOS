//
//  File.swift
//
//
//  Created by Nicolai Dam on 12/06/2023.
//

import Foundation
import UIKit

let appIDKey = "UFST-Client-ID"

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
    var requestWithDefaultHeaders = applyHeadersToRequest(request: request, appID: RequestBuilder.getAppID())
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
    let request = URLRequest(url: url)
    var requestWithDefaultHeaders = applyHeadersToRequest(request: request, appID: RequestBuilder.getAppID())
    requestWithDefaultHeaders.httpMethod = "POST"
    requestWithDefaultHeaders.httpBody = try! encoder.encode(requestBody)
    requestWithDefaultHeaders.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if !headers.isEmpty {
        var headerFields = requestWithDefaultHeaders.allHTTPHeaderFields ?? [:]
        headerFields.merge(headers, uniquingKeysWith: { $1 })
        requestWithDefaultHeaders.allHTTPHeaderFields = headerFields
    }
    return requestWithDefaultHeaders
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
    let request = URLRequest(url: url)
    var requestWithDefaultHeaders = applyHeadersToRequest(request: request, appID: RequestBuilder.getAppID())
    requestWithDefaultHeaders.httpMethod = "DELETE"
    requestWithDefaultHeaders.httpBody = try! encoder.encode(requestBody)
    requestWithDefaultHeaders.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if !headers.isEmpty {
        var headerFields = requestWithDefaultHeaders.allHTTPHeaderFields ?? [:]
        headerFields.merge(headers, uniquingKeysWith: { $1 })
        requestWithDefaultHeaders.allHTTPHeaderFields = headerFields
    }
    return requestWithDefaultHeaders
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
    let request = URLRequest(url: url)
    var requestWithDefaultHeaders = applyHeadersToRequest(request: request, appID: RequestBuilder.getAppID())
    requestWithDefaultHeaders.httpMethod = "PUT"
    requestWithDefaultHeaders.httpBody = try! encoder.encode(requestBody)
    requestWithDefaultHeaders.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if !headers.isEmpty {
        var headerFields = requestWithDefaultHeaders.allHTTPHeaderFields ?? [:]
        headerFields.merge(headers, uniquingKeysWith: { $1 })
        requestWithDefaultHeaders.allHTTPHeaderFields = headerFields
    }
    return requestWithDefaultHeaders
}

private func applyHeadersToRequest(request: URLRequest, appID: String) -> URLRequest {
    var copy = request
    var headers = request.allHTTPHeaderFields ?? [:]
    headers["X-UFST-Client-ID"] = appID
    headers["X-UFST-Client-Request-ID"] = UUID().uuidString
    headers["X-UFST-Client-Platform"] = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    headers["X-UFST-Client-Version"] = Bundle.main.versionNumber
    copy.allHTTPHeaderFields = headers
    return copy
}

public actor RequestBuilder {
    
    static func getAppID(
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
    
    /// App ID hat can be used by the client, for example if should be sent to Mixpanel or Firebase so tracing from Kibana is possible
    public static var appID: String {
        let appID = getAppID()
        return appID
    }
}

private extension Bundle {
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "-"
    }
}

extension URLRequest {
    /// Public helper that adds the UFST headers to a given request
    /// This func should be used on URLRequests from clients that are not using the request builders
    public func applyDefaultUFSTHeaders() -> Self {
        let requestWithHeaders: URLRequest = applyHeadersToRequest(request: self, appID: RequestBuilder.getAppID())
        return requestWithHeaders
    }
}
