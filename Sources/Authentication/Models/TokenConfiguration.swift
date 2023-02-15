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
    ///     apiKey: "+++++++++++",
    ///     clientID: "+++++++++++",
    ///     azureOrDcs: "azure",
    ///     nonce: "+++++++++++",
    ///     azure: AuthenticationHandler.AzureModel(name: "w20", email: "W20@BilletTest.onmicrosoft.com"),
    ///     authorizations: AuthenticationHandler.AuthorizationsModel(roles: ["IP.DigitalLogbog.Aktoer.Sagsbehandler.Kontrollant.PRG"])
    /// )
    /// ````
    public struct TokenConfiguration: Codable, Hashable {
        public static func == (lhs: AuthenticationHandler.TokenConfiguration, rhs: AuthenticationHandler.TokenConfiguration) -> Bool {
            lhs.apiKey == rhs.apiKey
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
            self.authenticatedUser = nil
            self.delegator = nil
        }
        
        public init(apiKey: String,
                    clientID: String,
                    azureOrDcs: String,
                    nonce: String,
                    authorizations: AuthorizationsModel,
                    authenticatedUser: AuthenticatedUserModel,
                    delegator: DelegatorModel) {
            self.apiKey = apiKey
            self.clientID = clientID
            self.azureOrDcs = azureOrDcs
            self.nonce = nonce
            self.authorizations = authorizations
            self.delegator = delegator
            self.authenticatedUser = authenticatedUser
            self.azure = nil
        }
        
        let apiKey: String
        let clientID: String
        let azureOrDcs: String
        let nonce: String
        let azure: AzureModel?
        let authorizations: AuthorizationsModel
        let authenticatedUser: AuthenticatedUserModel?
        let delegator: DelegatorModel?

        enum CodingKeys: String, CodingKey {
            case apiKey = "api-key"
            case clientID = "client_id"
            case azureOrDcs
            case nonce
            case azure
            case authorizations
            case authenticatedUser
            case delegator
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
    public struct AuthenticatedUserModel: Codable, Hashable {
        public init(skatQAALevel: String,
                    eIdentifier: String,
                    typeOfIdentifier: String,
                    alternateIdentifier: String,
                    alternateIdentifierType: String,
                    alternateName: String,
                    legalname: String,
                    typeOfActor: String,
                    typeOfPerson: String,
                    countryCode: String) {
            self.skatQAALevel = skatQAALevel
            self.eIdentifier = eIdentifier
            self.typeOfIdentifier = typeOfIdentifier
            self.alternateIdentifier = alternateIdentifier
            self.alternateIdentifierType = alternateIdentifierType
            self.alternateName = alternateName
            self.legalname = legalname
            self.typeOfActor = typeOfActor
            self.typeOfPerson = typeOfPerson
            self.countryCode = countryCode
        }
        
        let skatQAALevel: String
        let eIdentifier: String
        let typeOfIdentifier: String
        let alternateIdentifier: String
        let alternateIdentifierType: String
        let alternateName: String
        let legalname: String
        let typeOfActor: String
        let typeOfPerson: String
        let countryCode: String
    }
    public struct DelegatorModel: Codable, Hashable {
        public init(identifier: String,
                    typeOfIdentifier: String,
                    alternateIdentifier: String,
                    alternateIdentifierType: String,
                    alternateName: String,
                    legalname: String,
                    typeOfActor: String,
                    typeOfPerson: String,
                    countryCode: String) {
            self.identifier = identifier
            self.typeOfIdentifier = typeOfIdentifier
            self.alternateIdentifier = alternateIdentifier
            self.alternateIdentifierType = alternateIdentifierType
            self.alternateName = alternateName
            self.legalname = legalname
            self.typeOfActor = typeOfActor
            self.typeOfPerson = typeOfPerson
            self.countryCode = countryCode
        }
        
        let identifier: String
        let typeOfIdentifier: String
        let alternateIdentifier: String
        let alternateIdentifierType: String
        let alternateName: String
        let legalname: String
        let typeOfActor: String
        let typeOfPerson: String
        let countryCode: String
    }
}
