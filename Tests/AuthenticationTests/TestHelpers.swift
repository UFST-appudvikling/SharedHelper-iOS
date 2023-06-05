//
//  File.swift
//  
//
//  Created by Nicolai Dam on 03/06/2023.
//

import AuthenticationServices

@testable import Authentication
@testable import SecurityHandler

extension PKCEClient {
    
    static let failing = Self(
        generateCodeVerifier: { fatalError() },
        generateCodeChallenge: { _ in fatalError() }
    )
    
    static let empty = Self(
        generateCodeVerifier: { "" },
        generateCodeChallenge: { _ in "" }
    )
}

extension APIClient {
    
    static let failing = Self(
        getToken: { _ in fatalError() },
        getTokenAutomatic: { _ in fatalError() },
        getUserInfo: { _, _ in fatalError() },
        getAuthorizationCode: { _ in fatalError() }
    )
}

extension KeychainClient {
    
    static let failing = Self(
        getString: { _ in fatalError() },
        save: { _, _ in fatalError() },
        remove: { _ in fatalError() }
    )
}



extension AuthenticationHandler.Configuration {
    
    static let mock = Self.init(
        baseURL: "https://test.com",
        clientID: "client",
        authorizePath: "authorize",
        accessTokenPath: "accesstoken",
        userInfoPath: "userinfo",
        callBackURL: "scheme:/",
        callbackURLScheme: "scheme",
        scopes: ["scope1", "scope2"]
    )
}

extension AuthenticationHandler.TokenModel {
    
    static let mockValidToken = Self.init(
        accessToken: "sdlkfjsaldkfjnlksdnsd",
        expiresIn: 60,
        refreshExpiresIn: 299,
        refreshToken: "dsjkhbfsdjhfbsdjhfsb",
        tokenType: "tokenType",
        scope: ""
    )
    
    static let mockInValidToken = Self.init(
        accessToken: "sdlkfjsaldkfjnlksdnsd",
        expiresIn: -99,
        refreshExpiresIn: -299,
        refreshToken: "dsjkhbfsdjhfbsdjhfsb",
        tokenType: "tokenType",
        scope: ""
    )
}

extension AuthenticationHandlerTests {
    
    func makeInitialState(
        keychainClient: KeychainClient = .failing,
        apiClient: APIClient = .failing,
        date: Date = .init(timeIntervalSince1970: 0),
        pkceClient: PKCEClient = .failing,
        tokenIdentifier: String = "tokenIdentifier",
        sheetIsActive: Bool = false
    ) -> AuthenticationHandler {
        let authenticationHandler = AuthenticationHandler(
            sheetIsActive: sheetIsActive,
            loginType: .live(
                .init(
                    configuration: .mock,
                    contextProvider: ASPresentationAnchor(),
                    tokenIdentifier: tokenIdentifier
                )
            ),
            keychainClient: keychainClient,
            apiClient: apiClient,
            date: date,
            pkceClient: pkceClient
        )
        return authenticationHandler
    }
}
