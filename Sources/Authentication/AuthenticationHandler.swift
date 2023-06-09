//
//  File.swift
//  
//
//  Created by Emad Ghorbania on 20/09/2022.
//

import Foundation
import AuthenticationServices
import SecurityHandler

public final class AuthenticationHandler {
    
    /// Properties
    var sheetIsActive: Bool = false
    let loginType: LoginType
    let pkceVariables: PKCEVariables
    
    /// Dependencies
    var keychainClient: KeychainClient
    var apiClient: APIClient
    var date: () -> Date
    var pkceClient: PKCEClient
    
    
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
        self.keychainClient = .live
        self.apiClient = .live
        self.date = { Date() }
        self.pkceClient = .live
        let codeVerifier = self.pkceClient.generateCodeVerifier()
        let codeChallenge = self.pkceClient.generateCodeChallenge(codeVerifier)
        self.pkceVariables = .init(codeChallenge: codeChallenge, codeVerifier: codeVerifier)
    }
    
    /// Should be used for testing only and is therefore internal
    internal init(sheetIsActive: Bool, loginType: LoginType, keychainClient: KeychainClient, apiClient: APIClient, date: Date, pkceClient: PKCEClient) {
        self.sheetIsActive = sheetIsActive
        self.loginType = loginType
        self.keychainClient = keychainClient
        self.apiClient = apiClient
        self.date = { date }
        self.pkceClient = pkceClient
        let codeVerifier = self.pkceClient.generateCodeVerifier()
        let codeChallenge = self.pkceClient.generateCodeChallenge(codeVerifier)
        self.pkceVariables = .init(codeChallenge: codeChallenge, codeVerifier: codeVerifier)
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
        return try await apiClient.getUserInfo(token.0, input.configuration)
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
            return (try await apiClient.getTokenAutomatic(automatedLoginModel), .automatedLogin)
            
        case .live(let liveInput):
            
            if let wrappedToken = self.keychainClient.getString(liveInput.tokenIdentifier),
               let token = unwrap(wrappedToken: wrappedToken, now: self.date()) {
                
                if token.accessTokenIsValid(now: self.date()) {
                    
                    
                    return (token, .keychain)
                } else {
                    
                    return try await refreshTokenOrLogin(token: token, configuration: liveInput.configuration, tokenIdentifier: liveInput.tokenIdentifier)
                }
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
        guard let url = createAuthorizationURL(input: input, codeChallenge: self.pkceVariables.codeChallenge) else { throw AuthenticationHandler.CustomError.invalidURL }
        guard !self.sheetIsActive else { throw CustomError.internalError("Sheet is already active") }
        
        self.sheetIsActive = true
        let authorizationCodeResult = await apiClient.getAuthorizationCode(.init(authenticationHandlerObject: input.authenticationHandlerObject, callbackURLScheme: input.configuration.callbackURLScheme, authorizationURL: url))
        
        switch authorizationCodeResult {
            
        case .success(let authorizationCode):
            self.sheetIsActive = false
            let tokenModel = try await fetchToken(
                type: .postAuthorization(authorizationCode: authorizationCode),
                configuration: input.configuration,
                tokenIdentifier: input.tokenIdentifier
            )
            return tokenModel
            
        case .failure(let error):
            self.sheetIsActive = false
            throw error
        }
    }
    /// Checks if Token exist and it's valid and if It's not valid it invalidate the token.
    ///
    /// - Returns: Optinal ``AuthenticationHandler/TokenModel``
    public func checkTokenIfExistOnLive() -> TokenModel? {
        
        guard case .live(let input) = loginType else { return nil }
        
        guard let wrappedToken = self.keychainClient.getString(input.tokenIdentifier) else { return nil }
        
        if let token = unwrap(wrappedToken: wrappedToken, now: self.date()), token.refreshTokenIsValid(now: self.date()) {
            return token
        } else {
            _ = self.keychainClient.remove(input.tokenIdentifier)
            return nil
        }
    }
    /// Invalidate token from keychain
    public func logout() {
        
        guard case .live(let input) = loginType else { return }
        
        _ = self.keychainClient.remove(input.tokenIdentifier)
    }
}
// MARK: - Private Methodes
extension AuthenticationHandler {
    
    private func refreshTokenOrLogin(token: TokenModel, configuration: Configuration, tokenIdentifier: String) async throws -> (TokenModel, TokenSource) {
        if token.refreshTokenIsValid(now: self.date()) {
            let token = try await fetchToken(type: .refresh(refreshToken: token.refreshToken), configuration: configuration, tokenIdentifier: tokenIdentifier)
            return (token, .refresh)
        } else {
            return (try await loginByShowingSheetOnLive(), .loginSheet)
        }
    }
    
    private func fetchToken(type: GetTokenType, configuration: Configuration, tokenIdentifier: String) async throws -> AuthenticationHandler.TokenModel {
        do {
            let token = try await apiClient.getToken(.init(type: type, configuration: configuration, codeVerifier: self.pkceVariables.codeVerifier))
            _ = self.keychainClient.remove(tokenIdentifier)
            _ = self.keychainClient.save(token.wrap(now: self.date()), tokenIdentifier)
            return token
        } catch {
            _ = keychainClient.remove(tokenIdentifier)
            throw AuthenticationHandler.CustomError.invalidData
        }
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

public extension AuthenticationHandler {
    
     enum LoginType {
        case automatic(AuthenticationHandler.AutomatedLoginInput)
        case live(AuthenticationHandler.LiveLoginInput)
    }
     struct LiveLoginInput {
        
        let configuration: Configuration
        let authenticationHandlerObject: AuthenticationHandlerObject
        let tokenIdentifier: String
        
        public init(
            configuration: AuthenticationHandler.Configuration,
            contextProvider: ASPresentationAnchor,
            tokenIdentifier: String
        ) {
            self.configuration = configuration
            self.authenticationHandlerObject = AuthenticationHandlerObject(contextProvider: contextProvider)
            self.tokenIdentifier = tokenIdentifier
        }
    }
    
    struct AutomatedLoginInput: Codable, Equatable {
        
        let url: String
        let user: UserItem
        
        public init(url: String, user: UserItem) {
            self.url = url
            self.user = user
        }
    }
}

extension AuthenticationHandler {
    struct PKCEVariables {
        let codeChallenge: String?
        let codeVerifier: String?
    }
}
