//
//  File.swift
//
//
//  Created by Nicolai Dam on 12/06/2023.
//

import Foundation
import UIKit

/// Request for getting
/// Per default a request id, app version platform is in the header for better logging on the backend
/// - Parameters:
///   - url: url + path to hit
///   - parameters: url query params
///   - appID: App Identifier. The idea is that it should be persisted locally on the phone so the same identifier will be sent even when closing the app and open again. The app client has the responsibility to handle that.
///   - headers: extra heades
/// - Returns: Request

public func makeGetRequest(
    url: URL,
    parameters: [String: Any] = [:],
    appID: String? = nil,
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
    var requestWithDefaultHeaders = request.applyDefaultHeaders(appID: appID)
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
///   - appID: App Identifier. The idea is that it should be persisted locally on the phone so the same identifier will be sent even when closing the app and open again. The app client has the responsibility to handle that.
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
    appID: String? = nil,
    headers: [String: String] = [:]
) -> URLRequest {
    var request = URLRequest(url: url).applyDefaultHeaders(appID: appID)
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
///   - appID: App Identifier. The idea is that it should be persisted locally on the phone so the same identifier will be sent even when closing the app and open again. The app client has the responsibility to handle that.
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
    appID: String? = nil,
    headers: [String: String] = [:]
) -> URLRequest {
    var request = URLRequest(url: url).applyDefaultHeaders(appID: appID)
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
///   - appID: App Identifier. The idea is that it should be persisted locally on the phone so the same identifier will be sent even when closing the app and open again. The app client has the responsibility to handle that.
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
    appID: String? = nil,
    headers: [String: String] = [:]
) -> URLRequest {
    var request = URLRequest(url: url).applyDefaultHeaders(appID: appID)
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
    func applyDefaultHeaders(appID: String?) -> URLRequest {
        var copy = self
        var headers = self.allHTTPHeaderFields ?? [:]
        if let appID {
            headers["X-UFST-App-ID"] = appID
        }
        headers["X-UFST-Request-ID"] = UUID().uuidString
        headers["X-UFST-Platform"] = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
        headers["X-UFST-App-Version"] = Bundle.main.versionNumber
        copy.allHTTPHeaderFields = headers
        return copy
    }
}


public extension Bundle {
    
    var bundleId: String {
        return bundleIdentifier ?? ""
    }
    var versionNumber: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }
}
