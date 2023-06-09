//
//  File.swift
//  
//
//  Created by Nicolai Dam on 30/05/2023.
//

import AuthenticationServices
import Foundation
import SecurityHandler

/// Interface
struct APIClient {
    var getToken: (GetTokenRequestInput) async throws -> AuthenticationHandler.TokenModel
    var getTokenAutomatic: (_ automatedLoginModel: AuthenticationHandler.AutomatedLoginInput) async throws -> AuthenticationHandler.TokenModel
    var getUserInfo: (_ token: AuthenticationHandler.TokenModel, _ configuration: AuthenticationHandler.Configuration) async throws -> AuthenticationHandler.UserModel
    var getAuthorizationCode: (GetAuthorizationCodeInput) async -> Result<String, Error>
}

extension APIClient {
    
    /// Live implementation
    static let live = Self.init(
        getToken: { input in
            var body: Data?
            
            switch input.type {
            case .refresh(let refreshToken):
                body = createGetTokenBody(type: .refresh(refreshToken: refreshToken), configuration: input.configuration, codeVerifier: input.codeVerifier)
            case .postAuthorization(let authorizationCode):
                body = createGetTokenBody(type: .postAuthorization(authorizationCode: authorizationCode), configuration: input.configuration, codeVerifier: input.codeVerifier)
            }
            
            
            let request = try createTokenRequest(
                urlString: input.configuration.baseURL + input.configuration.accessTokenPath,
                method: "POST",
                header: ["Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"],
                body: body
            )
            
            if let response: AuthenticationHandler.TokenModel = try await sendRequest(request: request) {
                return response
            } else {
                throw AuthenticationHandler.CustomError.invalidData
            }
        },
        getTokenAutomatic: { automatedLoginModel in
            do {
                var jsonBody: Data?
                
                switch automatedLoginModel.user {
                case .azure(let azureUser):
                    jsonBody = azureUser.asJsonData
                case .dcs(let dcsUser):
                    jsonBody = dcsUser.asJsonData
                }
                
                let request = try createTokenRequest(
                    urlString: automatedLoginModel.url,
                    method: "POST",
                    header: ["Content-Type": "application/json"],
                    body: jsonBody
                )
                if let response: AuthenticationHandler.TokenModel = try await sendRequest(request: request) {
                    return response
                } else {
                    throw AuthenticationHandler.CustomError.invalidData
                }
            } catch let error {
                dump(error)
                throw error
            }
        },
        getUserInfo: { token, configuration in
            let request = try createUserRequest(
                urlString: configuration.baseURL + configuration.userInfoPath,
                method: "GET",
                header: ["Authorization": "Bearer \(token.accessToken)"]
            )
            
            if let response: AuthenticationHandler.UserModel = try await sendRequest(request: request) {
                return response
            } else {
                throw AuthenticationHandler.CustomError.invalidData
            }
        },
        getAuthorizationCode: { input in
            return await withCheckedContinuation { [authenticationHandlerObject = input.authenticationHandlerObject] continuation in
                
                let authenticationSession = ASWebAuthenticationSession(url: input.authorizationURL, callbackURLScheme: input.callbackURLScheme) { callbackURL, error in
                    if let error = error {
                        continuation.resume(returning: .failure(AuthenticationHandler.CustomError.dissmissLogin(error: error.localizedDescription)))
                    } else {
                        if
                            let callbackURL = callbackURL,
                            let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems,
                            let code = queryItems.first(where: { $0.name == "code" })?.value {
                            continuation.resume(returning: .success(code))
                        } else {
                            continuation.resume(returning: .failure(AuthenticationHandler.CustomError.invalidData))
                        }
                    }
                }
                authenticationSession.presentationContextProvider = authenticationHandlerObject
                authenticationSession.prefersEphemeralWebBrowserSession = true
                authenticationSession.start()
            }
        }
    )
}

struct GetTokenRequestInput {
    let type: GetTokenType
    let configuration: AuthenticationHandler.Configuration
    let codeVerifier: String?
}

struct GetAuthorizationCodeInput {
    let authenticationHandlerObject: AuthenticationHandlerObject
    let callbackURLScheme: String
    let authorizationURL: URL
}

enum GetTokenType {
    case postAuthorization(authorizationCode: String)
    case refresh(refreshToken: String)
}
