//
//  Networking.swift
//
//
//  Created by Emad Ghorbania on 10/06/2022.
//

import Foundation

/// NetworkingProtocol: This is where the method that executes the generic requests is located.
public protocol NetworkingProtocol {
    func sendRequest<Response: Codable>(request: URLRequest) async throws -> Response?
    func uploadMultipartFile<Response: Codable>(multipartForm: Networking.MultipartFormData, url: URL) async throws -> Response?
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
    func sendRequest<Response: Codable>(request: URLRequest) async throws -> Response? {
        do {
            let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
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
    func uploadMultipartFile<Response: Codable>(multipartForm: Networking.MultipartFormData, url: URL) async throws -> Response? {
        let request = URLRequest(url: url, multipartFormData: multipartForm)
        if let response: Response = try await sendRequest(request: request) {
            return response
        } else {
            return nil
        }
    }
}
