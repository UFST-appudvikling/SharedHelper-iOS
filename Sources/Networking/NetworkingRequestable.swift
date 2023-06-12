//
//  Endpoint.swift
//  
//
//  Created by Stig von der Ahé on 20/06/2022.
//

import Foundation

/// Requestable: A protocol to set up all endpoints for a given 'feature/flow'.
public protocol NetworkingRequestable {
    var baseURL: String { get }
    var path: String { get }
    var method: NetworkingRequestableMethod { get }
    var header: [String: String]? { get }
    var body: Data? { get }
}

public enum NetworkingRequestableMethod: String {
    case delete = "DELETE"
    case get = "GET"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
}


public extension Networking {
    static func makeURLRequest(request: NetworkingRequestable) throws -> URLRequest {
       
        guard let url = URL(string: request.baseURL + request.path) else {
            throw NetworkingError.invalidURL
        }
        
        var URLRequest = URLRequest(url: url)
        URLRequest.httpMethod = request.method.rawValue
        URLRequest.allHTTPHeaderFields = request.header
        
        print("Send request with url: == \(String(describing: URLRequest.url))")
        print("Send request with httpMethod: == \(String(describing: URLRequest.httpMethod))")
        print("Send request with headers: == \(String(describing: URLRequest.allHTTPHeaderFields))")
        
        if let body = request.body {
            print("Send request with body == \(String(data: body, encoding: .utf8)!)")
            URLRequest.httpBody = body
        }
        return URLRequest
    }
}

