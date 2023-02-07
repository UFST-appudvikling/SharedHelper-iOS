//
//  File.swift
//  
//
//  Created by Emad Ghorbaninia on 01/02/2023.
//

import Foundation
let decoder = JSONDecoder()
extension AuthenticationHandler {
    /// Configuration of ``TokenHandler`` to be able to work with
    /// - Example:
    /// ````
    /// AuthenticationHandler.TokenConfiguration
    /// (
    ///     baseURL: "https://example.com",
    ///     clientID: "+++++++",
    ///     authorizePath: "/auth/realms/++++++/protocol/openid-connect/auth",
    ///     accessTokenPath: "/auth/realms/++++++/protocol/openid-connect/token",
    ///     userInfoPath: "/auth/realms/++++++/protocol/openid-connect/userinfo",
    ///     callBackURL: "dk.++++.+++++.debug:/",
    ///     callbackURLScheme: "dk.++++.+++++.debug",
    ///     scopes: ["openid", "++++++"]
    ///)
    /// ````
    public struct TokenConfiguration: Codable, Hashable {
        public static func == (lhs: AuthenticationHandler.TokenConfiguration, rhs: AuthenticationHandler.TokenConfiguration) -> Bool {
            lhs.azure.email == rhs.azure.email
        }
        
        /// It's Configuration property to be used in all the logics in ``TokenHandler``
        /// - Parameters:
        ///   - apiKey: provide API Key for token handler
        ///   - azureOrDcs: Realms indecator
        ///   - nonce: provide nonce for token handler
        ///   - azure: Look at ``AuthenticationHandler.AzureModel``
        ///   - authorizations: ``AuthenticationHandler.AuthorizationsModel``
        ///   - Example:
        /// ````
        /// AuthenticationHandler.TokenConfiguration
        /// (
        ///     apiKey: "+++++++++++",
        ///     clientID: "+++++++++++",
        ///     azureOrDcs: "azure",
        ///     nonce: "+++++++++++",
        ///     azure: AuthenticationHandler.AzureModel(name: "w20", email: "W20@BilletTest.onmicrosoft.com"),
        ///     authorizations: AuthenticationHandler.AuthorizationsModel(roles: ["IP.DigitalLogbog.Aktoer.Sagsbehandler.Kontrollant.PRG"])
        /// )
        /// ````
        public init(apiKey: String,
                    clientID: String,
                    azureOrDcs: String,
                    nonce: String,
                    azure: AzureModel,
                    authorizations: AuthorizationsModel) {
            self.apiKey = apiKey
            self.clientID = clientID
            self.azureOrDcs = azureOrDcs
            self.nonce = nonce
            self.azure = azure
            self.authorizations = authorizations
        }
        
        let apiKey: String
        let clientID: String
        let azureOrDcs: String
        let nonce: String
        let azure: AzureModel
        let authorizations: AuthorizationsModel
        
        enum CodingKeys: String, CodingKey {
            case apiKey = "api-key"
            case clientID = "client_id"
            case azureOrDcs
            case nonce
            case azure
            case authorizations
        }
        var asJsonData: Data? {
            let encoder = JSONEncoder()
            let json = try? encoder.encode(self)
            return json
        }
    }
    public struct AuthorizationsModel: Codable, Hashable {
        public init(roles: [String]) {
            self.roles = roles
        }
        
        let roles: [String]
    }
    public struct AzureModel: Codable, Hashable{
        public init(name: String, email: String) {
            self.name = name
            self.email = email
        }
        
        let name: String
        let email: String
    }
    
    public struct AutomatedLoginModel: Decodable, Hashable {
        public init(url: String, user: AuthenticationHandler.TokenConfiguration) {
            self.url = url
            self.user = user
        }
        
        let url: String
        let user: TokenConfiguration
    }
    
}
