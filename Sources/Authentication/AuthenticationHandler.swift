//
//  File.swift
//  
//
//  Created by Emad Ghorbania on 20/09/2022.
//

import Foundation
import AuthenticationServices


/// Main functionality of this is like the following list:
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
public final class AuthenticationHandler: NSObject {
    // MARK: Properties
    internal let configuration: Configuration
    internal let contextProvider: ASPresentationAnchor
    // MARK: Methods
    /// You should use this method to be able to start using ``AuthenticationHandler``
    ///
    /// Inject ``Configuration`` and **ASPresentationAnchor** to the init function to be able to work with the library and look at **Example** to know how to do it.
    ///
    /// - Example:
    /// ````
    /// import AuthenticationServices
    /// import Authentication
    ///
    /// var contextProvider: ASPresentationAnchor?
    /// DispatchQueue.main.async {
    ///     let scenes = UIApplication.shared.connectedScenes
    ///     let windowScene = scenes.first as? UIWindowScene
    ///     contextProvider = windowScene?.windows.first
    /// }
    ///
    /// AuthenticationHandler(
    ///     configuration: AuthenticationHandler.Configuration(
    ///         baseURL: "https://billetautomat-keycloak-dcs-plugin-master-test.ocpt.ccta.dk",
    ///         clientID: "digital-logbog",
    ///         authorizePath: "/auth/realms/azure-uat/protocol/openid-connect/auth",
    ///         accessTokenPath: "/auth/realms/azure-uat/protocol/openid-connect/token",
    ///         userInfoPath: "/auth/realms/azure-uat/protocol/openid-connect/userinfo",
    ///         callBackURL: "dk.ufst.toldkontrol.debug:/",
    ///         callbackURLScheme: "dk.ufst.toldkontrol.debug",
    ///         scopes: ["openid", "digital-logbog"]
    ///     ),
    ///     contextProvider: contextProvider ?? ASPresentationAnchor()
    /// )
    /// ````
    /// - Parameter configuration: The only way you can using this lib, look at example
    /// - Parameter contextProvider: Provide a window to show the login, look at example
    public init(configuration: Configuration, contextProvider: ASPresentationAnchor) {
        self.configuration = configuration
        self.contextProvider = contextProvider
    }
    /// Gives User Info coming from OAuth server by Fetching token and Request to fetch user info
    ///
    /// - Fetch token by using ``fetchToken()``
    /// - Get UserInfo by using token coming from above and return it without changes
    ///
    /// - Returns: ``AuthenticationHandler/UserModel``
    /// - Throws: ``AuthenticationHandler/CustomError``
    public func getUser() async throws -> UserModel {
        let token = try await fetchToken()
        return try await getUserInfo(token: token)
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
    ///
    /// - Returns: ``AuthenticationHandler/TokenModel``
    /// - Throws: ``AuthenticationHandler/CustomError``
    public func fetchToken() async throws -> TokenModel {
        if let token = KeychainHelper.retrieveToken() {
            return try await validateTokenOrRefresh(token: token)
        } else {
            return try await login()
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
    public func login() async throws -> TokenModel {
        let callBackURL = await getAuthorizationCode()
        let tokenModel = try await getToken(authorizationCode: callBackURL.get())
        return tokenModel
    }
    /// Checks if Token exist and it's valid and if It's not valid it invalidate the token.
    ///
    /// - Returns: Optinal ``AuthenticationHandler/TokenModel``
    public func checkTokenIfExist() -> TokenModel? {
        if let token = KeychainHelper.retrieveToken(), token.refreshTokenIsValid {
            return token
        } else {
            KeychainHelper.invalidateToken()
            return nil
        }
    }
    /// Invalidate token from keychain
    public func logout() {
        KeychainHelper.invalidateToken()
    }
    /// Shows How to initial configuration
    /// - Warning:This should not be used any project as a public init
    private override init() {
        self.configuration = AuthenticationHandler.Configuration(
            baseURL: "https://billetautomat-keycloak-dcs-plugin-master-test.ocpt.ccta.dk",
            clientID: "digital-logbog",
            authorizePath: "/auth/realms/azure-uat/protocol/openid-connect/auth",
            accessTokenPath: "/auth/realms/azure-uat/protocol/openid-connect/token",
            userInfoPath: "/auth/realms/azure-uat/protocol/openid-connect/userinfo",
            callBackURL: "dk.ufst.toldkontrol.debug:/",
            callbackURLScheme: "dk.ufst.toldkontrol.debug",
            scopes: ["openid", "digital-logbog"]
        )
        var contextProvider: ASPresentationAnchor?
        DispatchQueue.main.async {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            contextProvider = windowScene?.windows.first
        }
        self.contextProvider = contextProvider ?? ASPresentationAnchor()
    }
}
// MARK: - Private Methodes
extension AuthenticationHandler {
    // MARK: Handler Methodes
    private func validateTokenOrRefresh(token: TokenModel) async throws -> TokenModel {
        if token.accessTokenIsValid {
            return token
        } else {
            return try await refreshTokenOrLogin(token: token)
        }
    }
    private func refreshTokenOrLogin(token: TokenModel) async throws -> TokenModel {
        if token.refreshTokenIsValid {
            return try await getToken(refreshToken: token.refreshToken)
        } else {
            return try await login()
        }
    }

    // MARK: Networking Methods
    private func getAuthorizationCode () async -> Result<String, Error> {
        return await withCheckedContinuation { continuation in
            
            guard let url = createAuthorizationURL() else { return continuation.resume(returning: .failure(CustomError.invalidURL)) }
            
            let authenticationSession = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: self.configuration.callbackURLScheme) { callbackURL, error in
                    if let error = error {
                        continuation.resume(returning: .failure(error))
                    } else {
                        if
                            let callbackURL = callbackURL,
                            let queryItems = URLComponents(string: callbackURL.absoluteString)?.queryItems,
                            let code = queryItems.first(where: { $0.name == "code" })?.value
                        {
                            continuation.resume(returning: .success(code))
                        } else {
                            continuation.resume(returning: .failure(CustomError.invalidData))
                        }
                    }
                }
            
            authenticationSession.presentationContextProvider = self
            authenticationSession.prefersEphemeralWebBrowserSession = true
            
            if !authenticationSession.start() {
                continuation.resume(returning: .failure(CustomError.internalError("Failed to start ASWebAuthenticationSession")))
            }
            
        }
    }
    private func getToken(authorizationCode: String? = nil, refreshToken: String? = nil) async throws -> TokenModel {
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
                header: ["Content-Type" : "application/x-www-form-urlencoded; charset=UTF-8"],
                body: body
            )
            KeychainHelper.invalidateToken()
            if let response = try await sendRequest(request: request, responseType: TokenModel.self) {
                KeychainHelper.storeToken(response)
                return response
            } else {
                throw CustomError.invalidData
            }
        } catch let error {
            if case let CustomError.unexpectedStatusCode(code) = error, (400..<500).contains(code) {
                return try await login()
            } else {
                throw error
            }
        }
    }
    private func getUserInfo(token: TokenModel) async throws -> UserModel {
        do {

            let request = try createUserRequest(
                urlString: configuration.baseURL + configuration.userInfoPath,
                method: "GET",
                header: ["Authorization" : "Bearer \(token.accessToken)"]
            )

            if let response = try await sendRequest(request: request, responseType: UserModel.self) {
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
        return self.contextProvider
  }
}
