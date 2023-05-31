//
//  File.swift
//  
//
//  Created by Emad Ghorbania on 20/09/2022.
//

import Foundation
import AuthenticationServices
import UIKit
import SecurityHandler

public final class AuthenticationHandler: NSObject, ObservableObject {
    
    // MARK: Properties
    internal var sheetIsActive: Bool = false
    internal var loginType: LoginType
    
    public enum LoginType {
        case automatic(AuthenticationHandler.AutomatedLoginInput)
        case live(AuthenticationHandler.LiveLoginInput)
    }
    
    // MARK: Methods
    /// Initialise a AuthenticationHandler object to be able to start using ``AuthenticationHandler``
    /// Choose between automated login or live
    ///
    /// When initialising automated login provide a user of the type UserItem
    /// To get a user of this type use the AutomatedLoginSelection selection view and a JSON file in the AutmatedLoginJSON format as injection
    /// When a user is picked from the AutomatedLoginSelection view you should override the AuthenticationHandler object in the given app 
    ///
    ///
    /// - Example of live usage:
    /// ````
    ///    var contextProvider: ASPresentationAnchor?
    ///    DispatchQueue.main.async {
    ///        let scenes = UIApplication.shared.connectedScenes
    ///        let windowScene = scenes.first as? UIWindowScene
    ///        contextProvider = windowScene?.windows.first
    ///    }
    ///
    ///    let authenticationHandler = AuthenticationHandler(
    ///        loginType: .live(
    ///            AuthenticationHandler.LiveLoginInput(
    ///                configuration: AuthenticationHandler.Configuration(
    ///                    baseURL: "https://example.com",
    ///                    clientID: "+++++++",
    ///                    authorizePath: "/auth/realms/++++++/protocol/openid-connect/auth",
    ///                    accessTokenPath: "/auth/realms/++++++/protocol/openid-connect/token",
    ///                    userInfoPath: "/auth/realms/++++++/protocol/openid-connect/userinfo",
    ///                    callBackURL: "dk.++++.+++++.debug:/",
    ///                    callbackURLScheme: "dk.++++.+++++.debug",
    ///                    scopes: ["openid", "++++++"]
    ///                ),
    ///                contextProvider: contextProvider ?? ASPresentationAnchor(),
    ///                tokenIdentifier: Bundle.main.bundleIdentifier!,
    ///            )
    ///        )
    ///    )
    /// ````
    /// - Example for automated login usage:
    /// ````
    ///    let authenticationHandler = AuthenticationHandler(
    ///        loginType: .automatic(
    ///            AuthenticationHandler.AutomatedLoginInput(
    ///                url: "https://example.com",
    ///                user: user
    ///            )
    ///        )
    ///    )
    /// ````
    public init(loginType: LoginType) {
        self.loginType = loginType
    }
    
    /// Gives User Info coming from OAuth server by Fetching token and Request to fetch user info
    ///
    /// - Fetch token by using ``fetchToken()``
    /// - Get UserInfo by using token coming from above and return it without changes
    /// - Returns: ``AuthenticationHandler/UserModel``
    /// - Throws: ``AuthenticationHandler/CustomError``
    public func getUser() async throws -> UserModel {
        
        guard case .live(let input) = loginType else { throw CustomError.noAutomatedLoginSupport }
        
        let token = try await fetchToken()
        return try await getUserInfo(token: token.0, configuration: input.configuration)
    }
    /// Give you the token, either from Keychain or login user by using AuthenticationServices also Store it in Keychain
    ///
    /// - Fetch token from Keychain
    ///     - Validate token if there is a token in Keychain
    ///         - Return token if it's valid
    ///         - Refresh token if it's not valid
    ///             - Refresh token if refreshtToken is valid
    ///             - Navigate to Login if refreshToken is not valid
    ///     - Navigate to Login if there is not a token in Keychain
    ///         - Login flow
    ///             - Get authorization code
    ///             - Fetch token using the authorization code
    /// - Example:
    /// ````
    /// Task {
    ///    let token = try await authHandler.fetchToken().0
    /// }
    /// ````
    /// - Returns: (``AuthenticationHandler/TokenModel``, ``AuthenticationHandler/TokenSource``)
    /// - Throws: ``AuthenticationHandler/CustomError``
    public func fetchToken() async throws -> (TokenModel, TokenSource) {
        
        switch loginType {
        case .automatic(let automatedLoginModel):
            return (try await getTokenAutomatic(automatedLoginModel: automatedLoginModel), .automatedLogin)
            
        case .live(let liveInput):
            if let wrappedToken = SecurityHandler.KeychainHelper.string(matching: liveInput.tokenIdentifier),
               let token = AuthenticationHandler.unwrap(wrappedToken: wrappedToken) {
                return try await validateTokenOrRefresh(token: token)
            } else {
                return (try await loginByShowingSheetOnLive(), .loginSheet)
            }
        }
    }

    /// Force user to Login by using AuthenticationServices
    /// - Login flow
    ///     - Get authorization code
    ///     - Fetch token using the authorization code
    /// - Warning: It wont use the stored Token from Keychain and **Force user to login**.
    ///     If you just want the Token use ``fetchToken()``
    /// - Returns: discardableResult: ``AuthenticationHandler/TokenModel``
    /// - Throws: ``AuthenticationHandler/CustomError``
    @discardableResult
    public func loginByShowingSheetOnLive() async throws -> TokenModel {
        
        guard case .live(let input) = loginType else { throw CustomError.noAutomatedLoginSupport }
        
        let callBackURL = await getAuthorizationCode()
        let tokenModel = try await getTokenLive(authorizationCode: callBackURL.get(), configuration: input.configuration)
        return tokenModel
    }
    /// Checks if Token exist and it's valid and if It's not valid it invalidate the token.
    ///
    /// - Returns: Optinal ``AuthenticationHandler/TokenModel``
    public func checkTokenIfExistOnLive() -> TokenModel? {
        
        guard case .live(let input) = loginType else { return nil }
        
        guard let wrappedToken = SecurityHandler.KeychainHelper.string(matching: input.tokenIdentifier) else { return nil }
        if let token = AuthenticationHandler.unwrap(wrappedToken: wrappedToken), token.refreshTokenIsValid {
            return token
        } else {
            SecurityHandler.KeychainHelper.remove(identifier: input.tokenIdentifier)
            return nil
        }
    }
    /// Invalidate token from keychain
    public func logout() {
        
        guard case .live(let input) = loginType else { return }
        
        SecurityHandler.KeychainHelper.remove(identifier: input.tokenIdentifier)
    }
}
// MARK: - Private Methodes
extension AuthenticationHandler {
    // MARK: Handler Methodes
    private func validateTokenOrRefresh(token: TokenModel) async throws -> (TokenModel, TokenSource) {
        if token.accessTokenIsValid {
            return (token, .keychain)
        } else {
            switch loginType {
            case .automatic(let automatedLoginModel):
                return (try await getTokenAutomatic(automatedLoginModel: automatedLoginModel), .automatedLogin)
            case .live(let liveLoginModel):
                return try await refreshTokenOrLogin(token: token, configuration: liveLoginModel.configuration)
            }
        }
    }
    private func refreshTokenOrLogin(token: TokenModel, configuration: Configuration) async throws -> (TokenModel, TokenSource) {
        if token.refreshTokenIsValid {
            return (try await getTokenLive(refreshToken: token.refreshToken, configuration: configuration), .refresh)
        } else {
            return (try await loginByShowingSheetOnLive(), .loginSheet)
        }
    }
    // MARK: Networking Methods
    private func getAuthorizationCode () async -> Result<String, Error> {
        
        guard case .live(let input) = loginType else { return .failure(CustomError.noAutomatedLoginSupport)  }
        
        return await withCheckedContinuation { [weak self] continuation in
            guard let self = self else { return continuation.resume(returning: .failure(CustomError.invalidData)) }
            guard let url = createAuthorizationURL() else { return continuation.resume(returning: .failure(CustomError.invalidURL)) }

            let configuration = input.configuration
            if !sheetIsActive {
                let authenticationSession = ASWebAuthenticationSession(url: url, callbackURLScheme: configuration.callbackURLScheme) { [weak self] callbackURL, error in
                    self?.sheetIsActive = false
                    if let error = error {
                        continuation.resume(returning: .failure(CustomError.dissmissLogin(error: error.localizedDescription)))
                    } else {
                        if
                            let callbackURL = callbackURL,
                            let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems,
                            let code = queryItems.first(where: { $0.name == "code" })?.value {
                            continuation.resume(returning: .success(code))
                        } else {
                            continuation.resume(returning: .failure(CustomError.invalidData))
                        }
                    }
                }
                authenticationSession.presentationContextProvider = self
                authenticationSession.prefersEphemeralWebBrowserSession = true
                sheetIsActive = authenticationSession.start()
            } else {
                continuation.resume(returning: .failure(CustomError.internalError("It's already there")))
            }
        }
    }
    private func getTokenLive(authorizationCode: String? = nil, refreshToken: String? = nil, configuration: Configuration) async throws -> TokenModel {
        
        guard case .live(let input) = loginType else { throw CustomError.noAutomatedLoginSupport }
        
        do {

            var body: Data?
            if let refreshToken = refreshToken {
                body = createBody(refreshToken: refreshToken)
            } else if let code = authorizationCode {
                body = createBody(code: code)
            }

            let request = try createTokenRequest(
                urlString: configuration.baseURL + configuration.accessTokenPath,
                method: "POST",
                header: ["Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"],
                body: body
            )
            if let response: TokenModel = try await sendRequest(request: request) {
                SecurityHandler.KeychainHelper.remove(identifier: input.tokenIdentifier)
                SecurityHandler.KeychainHelper.create(value: response.wrap, forIdentifier: input.tokenIdentifier)
                return response
            } else {
                SecurityHandler.KeychainHelper.remove(identifier: input.tokenIdentifier)
                throw CustomError.invalidData
            }
        } catch let error {
            SecurityHandler.KeychainHelper.remove(identifier: input.tokenIdentifier)

            if case let CustomError.unexpectedStatusCode(code) = error, (400..<500).contains(code) {
                return try await loginByShowingSheetOnLive()
            } else {
                throw error
            }
        }
    }
    private func getTokenAutomatic(automatedLoginModel: AuthenticationHandler.AutomatedLoginInput) async throws -> TokenModel {
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
            if let response: TokenModel = try await sendRequest(request: request) {
                return response
            } else {
                throw CustomError.invalidData
            }
        } catch let error {
            throw error
        }
    }
    private func getUserInfo(token: TokenModel, configuration: Configuration) async throws -> UserModel {
        do {

            let request = try createUserRequest(
                urlString: configuration.baseURL + configuration.userInfoPath,
                method: "GET",
                header: ["Authorization": "Bearer \(token.accessToken)"]
            )

            if let response: UserModel = try await sendRequest(request: request) {
                return response
            } else {
                throw CustomError.invalidData
            }
        } catch let error {
            throw error
        }
    }
}
// MARK: - Protocol Handlers
extension AuthenticationHandler: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        guard case .live(let input) = loginType else { fatalError() }
        return input.contextProvider
  }
}


/**
 An extension for the `AuthenticationHandler` that provides a method to decode a JWT payload.

 This extension provides a method `getPayload` that takes a decodable payload type and an access token as input.
 The method returns an instance of the payload type, or `nil` if decoding fails.
*/
extension AuthenticationHandler {
    /**
     Decodes a JWT payload into a specified decodable type.
     
     - Parameters:
        - type: The `Decodable` type to decode the payload into.
        - accessToken: A JWT access token as a `String`.
     
     - Returns: An instance of the provided payload type, or `nil` if decoding fails.
     */
    public func getPayload<Payload: Decodable>(_ type: Payload.Type, accessToken: String)-> Payload? {
        // Helper function to decode base64URL encoded strings
        let encodedData = { (string: String) -> Data? in
            var encodedString = string.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
            
            switch (encodedString.utf16.count % 4) {
            case 2:     encodedString = "\(encodedString)=="
            case 3:     encodedString = "\(encodedString)="
            default:    break
            }
            
            return Data(base64Encoded: encodedString)
        }
        
        let components = accessToken.components(separatedBy: ".")
        
        guard components.count == 3, let payloadData = encodedData(components[1] as String) else { return nil }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            return try decoder.decode(Payload.self, from: payloadData)
            
        } catch {
            return nil
        }
    }
}

extension AuthenticationHandler {
    public struct AutomatedLoginInput: Codable, Equatable {
        
        let url: String
        let user: UserItem
        
        public init(url: String, user: UserItem) {
            self.url = url
            self.user = user
        }
    }
}

extension AuthenticationHandler {
    public struct LiveLoginInput {
        
        let configuration: Configuration
        let contextProvider: ASPresentationAnchor
        let tokenIdentifier: String
        
        public init(
            configuration: AuthenticationHandler.Configuration,
            contextProvider: ASPresentationAnchor,
            tokenIdentifier: String
        ) {
            self.configuration = configuration
            self.contextProvider = contextProvider
            self.tokenIdentifier = tokenIdentifier
        }
    }
}
