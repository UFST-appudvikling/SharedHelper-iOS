//
//  Networking.swift
//
//
//  Created by Emad Ghorbania on 10/06/2022.
//

import Foundation

/// NetworkingProtocol: This is where the method that executes the generic requests is located.
public protocol NetworkingProtocol {
    func sendRequest<Response: Codable>(request: URLRequest, sessionDelegate: URLSessionTaskDelegate?) async throws -> Response?
}


public final class Networking: NetworkingProtocol {
    public let session: URLSession
    
    public init(configuration: URLSessionConfiguration) {
        self.session = URLSession(configuration: configuration)
    }
    public convenience init() {
        self.init(configuration: .default)
    }
}

public extension NetworkingProtocol {
    @discardableResult
    func sendRequest<Response: Codable>(request: URLRequest, sessionDelegate: URLSessionTaskDelegate? = nil) async throws -> Response? {
        let session: URLSession
          if let delegate = sessionDelegate {
              session = URLSession(configuration: .default, delegate: delegate, delegateQueue: nil)
          } else {
              session = URLSession.shared
          }

        do {
            let (data, response) = try await session.data(for: request)
            guard let response = response as? HTTPURLResponse else {
                throw NetworkingError.noResponse
            }
            switch response.statusCode {
                
            case 200...299:
                if data.isEmpty {
                    return nil
                } else {
                    let decoder = JSONDecoder()
                    // allows the conversion of the Date data type and adds a Z on the Date
                    decoder.dateDecodingStrategy = .iso8601
                    guard let decodedResponse = try? decoder.decode(Response.self, from: data) else { throw NetworkingError.decodingError }
                    return decodedResponse
                }
            case 401:
                throw NetworkingError.unauthorized(response.statusCode)
            case 402...499:
                throw NetworkingError.clientEntityError(data: data, code: response.statusCode)
            case 500...599:
                throw NetworkingError.backendError(response.statusCode)
            default:
                throw NetworkingError.unexpectedStatusCode(response.statusCode)
            }
        } catch let error {
            if let error = error as? URLError {
                throw NetworkingError.urlError(error.errorCode, error.localizedDescription)
            } else {
                throw error
            }
        }
    }
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
