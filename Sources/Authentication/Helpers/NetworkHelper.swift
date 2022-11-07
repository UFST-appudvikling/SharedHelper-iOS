//
//  File.swift
//  
//
//  Created by Emad Ghorbania on 21/09/2022.
//

import Foundation
extension AuthenticationHandler {
    func sendRequest<Response: Codable>(request: URLRequest, responseType: Response.Type?) async throws -> Response? {
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
#if DEBUG
                    let encodedData = NSString(data: data, encoding: String.Encoding.utf8.rawValue)!
                    print("Printing billetautomaten request:")
                    dump(encodedData)
#endif
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    guard let responseType = responseType,
                          let decodedResponse = try? decoder.decode(responseType, from: data)
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
        let queryItems = [
          URLQueryItem(name: "client_id", value: configuration.clientID),
          URLQueryItem(name: "redirect_uri", value: self.configuration.callBackURL),
          URLQueryItem(name: "response_type", value: "code"),
          URLQueryItem(name: "scope", value: self.configuration.scopes.joined(separator: " ")),
          URLQueryItem(name: "code_challenge_method", value: "S256"),
          URLQueryItem(name: "code_challenge", value: configuration.codeChallenge)
        ]
        guard let accessTokenURL = URL(string: self.configuration.baseURL + self.configuration.authorizePath) else { return nil }
        return createUrlComponents(url: accessTokenURL, queryItems: queryItems).url
    }
    func createTokenRequest(urlString: String, method: String, header: [String : String], body: Data?) throws -> URLRequest {
        guard
            let url = URL(string: urlString)
        else { throw CustomError.invalidURL }
        
        var URLRequest = URLRequest(url: url)
        URLRequest.httpMethod = method
        URLRequest.allHTTPHeaderFields = header
        URLRequest.httpBody = body
        return URLRequest
    }
    func createUserRequest(urlString: String, method: String, header: [String : String]) throws -> URLRequest {
        guard
            let url = URL(string: urlString)
        else { throw CustomError.invalidURL }
        
        var URLRequest = URLRequest(url: url)
        URLRequest.httpMethod = method
        URLRequest.allHTTPHeaderFields = header
        return URLRequest
    }
    func createBody(code: String? = nil, refreshToken: String? = nil) -> Data? {
        
        var queryItems = [
          URLQueryItem(name: "code_verifier", value: self.configuration.codeVerifier),
          URLQueryItem(name: "redirect_uri", value: self.configuration.callBackURL),
          URLQueryItem(name: "client_id", value: self.configuration.clientID),
        ]
        if let code = code {
            queryItems.append(URLQueryItem(name: "code", value: code))
            queryItems.append(URLQueryItem(name: "grant_type", value: "authorization_code"))
        } else if let refreshToken = refreshToken {
            queryItems.append(URLQueryItem(name: "refresh_token", value: refreshToken))
            queryItems.append(URLQueryItem(name: "grant_type", value: "refresh_token"))
        }
        guard let accessTokenURL = URL(string: self.configuration.baseURL) else { return nil }
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
