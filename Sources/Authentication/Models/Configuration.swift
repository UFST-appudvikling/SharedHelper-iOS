//
//  File.swift
//  
//
//  Created by Emad Ghorbania on 21/09/2022.
//

import Foundation
public extension AuthenticationHandler {
    
    /// Configuration of ``AuthenticationHandler`` to be able to work with
    /// - Example:
    /// ````
    /// AuthenticationHandler.Configuration
    /// (
    ///     baseURL: "https://example.com",
    ///     clientID: "+++++++",
    ///     authorizePath: "/auth/realms/++++++/protocol/openid-connect/auth",
    ///     accessTokenPath: "/auth/realms/++++++/protocol/openid-connect/token",
    ///     userInfoPath: "/auth/realms/++++++/protocol/openid-connect/userinfo",
    ///     callbackURLScheme: "dk.++++.+++++.debug",
    ///     scopes: ["openid", "++++++"]
    ///)
    /// ````
    struct Configuration {
        /// It's Configuration property to be used in all the logics in ``AuthenticationHandler``
        /// - Parameters:
        ///   - baseURL: BaseURL for OAuth2
        ///   - clientID: Needed for Getting the AuthorizationCode
        ///   - authorizePath: Path for Authorization Api
        ///   - accessTokenPath: Path for Token Api
        ///   - userInfoPath: Path for UserInfo Api
        ///   - callbackURLScheme: Eider custom registered Scheme or Bundle ID
        ///   - scopes: Array of scopes for using OAuth2
        ///
        ///   - Example:
        /// ````
        /// AuthenticationHandler.Configuration
        /// (
        ///     baseURL: "https://example.com",
        ///     clientID: "+++++++",
        ///     authorizePath: "/auth/realms/++++++/protocol/openid-connect/auth",
        ///     accessTokenPath: "/auth/realms/++++++/protocol/openid-connect/token",
        ///     userInfoPath: "/auth/realms/++++++/protocol/openid-connect/userinfo",
        ///     callbackURLScheme: "dk.++++.+++++.debug",
        ///     scopes: ["openid", "++++++"]
        ///)
        /// ````
        public init (
            baseURL: String,
            clientID: String,
            authorizePath: String,
            accessTokenPath: String,
            userInfoPath: String,
            callbackURLScheme: String,
            scopes: [String]
        ) {
            self.baseURL = baseURL
            self.clientID = clientID
            self.authorizePath = authorizePath
            self.accessTokenPath = accessTokenPath
            self.userInfoPath = userInfoPath
            self.callbackURLScheme = callbackURLScheme
            self.scopes = scopes
            
            self.codeVerifier = Configuration.generateCodeVerifier()
            self.codeChallenge = Configuration.generateCodeChallenge(codeVerifier: self.codeVerifier)
        }
        
        let codeVerifier: String?
        let codeChallenge: String?
        let baseURL: String
        let clientID: String
        let authorizePath: String
        let accessTokenPath: String
        let userInfoPath: String
        let callbackURLScheme: String
        let scopes: [String]
    }
}
