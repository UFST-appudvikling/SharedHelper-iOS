//
//  File.swift
//  
//
//  Created by Emad Ghorbania on 21/09/2022.
//

import Foundation
extension AuthenticationHandler {
    func sendRequest<Response: Codable>(request: URLRequest) async throws -> Response? {
        do {
            let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
            guard let response = response as? HTTPURLResponse else {
                throw CustomError.noResponse
            }
            switch response.statusCode {
                
            case 200...299:
                if data.isEmpty {
                    return nil
                } else {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    guard let decodedResponse = try? decoder.decode(Response.self, from: data)
                    else {
                        throw CustomError.decodingError
                    }
                    return decodedResponse
                }
            default:
                throw CustomError.unexpectedStatusCode(response.statusCode)
            }
        } catch let error {
            throw error
        }
    }
}

extension AuthenticationHandler {
    func createAuthorizationURL() -> URL? {
        
        guard case .live(let input) = loginType else { fatalError("This method is only used for live login, not automated") }
        
        let configuration = input.configuration
        guard let accessTokenURL = URL(string: configuration.baseURL + configuration.authorizePath) else { return nil }

        let queryItems = [
          URLQueryItem(name: "client_id", value: configuration.clientID),
          URLQueryItem(name: "redirect_uri", value: configuration.callBackURL),
          URLQueryItem(name: "response_type", value: "code"),
          URLQueryItem(name: "scope", value: configuration.scopes.joined(separator: " ")),
          URLQueryItem(name: "code_challenge_method", value: "S256"),
          URLQueryItem(name: "code_challenge", value: configuration.codeChallenge)
        ]
        return createUrlComponents(url: accessTokenURL, queryItems: queryItems).url
    }
    func createTokenRequest(urlString: String, method: String, header: [String: String], body: Data?) throws -> URLRequest {
        guard
            let url = URL(string: urlString)
        else { throw CustomError.invalidURL }
        
        var URLRequest = URLRequest(url: url)
        URLRequest.httpMethod = method
        URLRequest.allHTTPHeaderFields = header
        URLRequest.httpBody = body
        return URLRequest
    }
    func createUserRequest(urlString: String, method: String, header: [String: String]) throws -> URLRequest {
        guard
            let url = URL(string: urlString)
        else { throw CustomError.invalidURL }
        
        var URLRequest = URLRequest(url: url)
        URLRequest.httpMethod = method
        URLRequest.allHTTPHeaderFields = header
        return URLRequest
    }
    func createBody(code: String? = nil, refreshToken: String? = nil) -> Data? {
        
        guard case .live(let input) = loginType else { fatalError("This method is only used for live login, not automated") }
        
        let configuration = input.configuration
        guard let accessTokenURL = URL(string: input.configuration.baseURL) else { fatalError() }

        var queryItems = [
          URLQueryItem(name: "code_verifier", value: configuration.codeVerifier),
          URLQueryItem(name: "redirect_uri", value: configuration.callBackURL),
          URLQueryItem(name: "client_id", value: configuration.clientID),
        ]
        if let code = code {
            queryItems.append(URLQueryItem(name: "code", value: code))
            queryItems.append(URLQueryItem(name: "grant_type", value: "authorization_code"))
        } else if let refreshToken = refreshToken {
            queryItems.append(URLQueryItem(name: "refresh_token", value: refreshToken))
            queryItems.append(URLQueryItem(name: "grant_type", value: "refresh_token"))
        }
        return createUrlComponents(url: accessTokenURL, queryItems: queryItems).query?.data(using: .utf8)
    }
    func createUrlComponents(url: URL, queryItems: [URLQueryItem]?) -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = url.scheme
        urlComponents.host = url.host
        urlComponents.path = url.path
        urlComponents.queryItems = queryItems
        return urlComponents
    }
}
