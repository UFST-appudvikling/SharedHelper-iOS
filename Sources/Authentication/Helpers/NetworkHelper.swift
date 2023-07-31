//
//  File.swift
//  
//
//  Created by Emad Ghorbania on 21/09/2022.
//

import Foundation

func sendRequest<Response: Codable>(request: URLRequest) async throws -> Response? {
    do {
        let (data, response) = try await URLSession.shared.data(for: request, delegate: nil)
        guard let response = response as? HTTPURLResponse else {
            throw AuthenticationHandler.CustomError.noResponse
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
                    throw AuthenticationHandler.CustomError.decodingError
                }
                return decodedResponse
            }
        default:
            throw AuthenticationHandler.CustomError.unexpectedStatusCode(response.statusCode)
        }
    } catch let error {
        dump(error)
        throw error
    }
}


func createAuthorizationURL(input: AuthenticationHandler.LiveLoginInput, codeChallenge: String?) -> URL? {
        
    let configuration = input.configuration
    guard let accessTokenURL = URL(string: configuration.baseURL + configuration.authorizePath) else { return nil }
    
    let queryItems = [
        URLQueryItem(name: "client_id", value: configuration.clientID),
        URLQueryItem(name: "redirect_uri", value: configuration.callBackURL),
        URLQueryItem(name: "response_type", value: "code"),
        URLQueryItem(name: "scope", value: configuration.scopes.joined(separator: " ")),
        URLQueryItem(name: "code_challenge_method", value: "S256"),
        URLQueryItem(name: "code_challenge", value: codeChallenge)
    ]
    return createUrlComponents(url: accessTokenURL, queryItems: queryItems).url
}
func createTokenRequest(urlString: String, method: String, header: [String: String], body: Data?) throws -> URLRequest {
    guard
        let url = URL(string: urlString)
    else { throw AuthenticationHandler.CustomError.invalidURL }
    
    var URLRequest = URLRequest(url: url)
    URLRequest.httpMethod = method
    URLRequest.allHTTPHeaderFields = header
    URLRequest.httpBody = body
    return URLRequest
}

func createGetTokenBody(type: GetTokenType, configuration: AuthenticationHandler.Configuration, codeVerifier: String?) -> Data? {
        
    guard let accessTokenURL = URL(string: configuration.baseURL) else { fatalError() }
    
    var queryItems = [
        URLQueryItem(name: "code_verifier", value: codeVerifier),
        URLQueryItem(name: "redirect_uri", value: configuration.callBackURL),
        URLQueryItem(name: "client_id", value: configuration.clientID),
    ]
    
    switch type {
    case .postAuthorization(authorizationCode: let authorizationCode):
        queryItems.append(URLQueryItem(name: "code", value: authorizationCode))
        queryItems.append(URLQueryItem(name: "grant_type", value: "authorization_code"))
    case .refresh(refreshToken: let refreshToken):
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

