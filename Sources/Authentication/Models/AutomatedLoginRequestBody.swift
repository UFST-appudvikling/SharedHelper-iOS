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
    public struct AutomatedLoginRequestBody: Codable  {
        

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
        
        let apiKey: String
        let clientID: String
        let azureOrDcs: String
        let nonce: String
        let azure: Azure
        let delegate: Delegate?
        let authorizations: AuthorizationsModel
        let authenticatedUser: AuthenticatedUser? //azure related only
        let delegator: Delegator?

        public init(apiKey: String, clientID: String, azureOrDcs: String, nonce: String, azure: AuthenticationHandler.Azure, delegate: Delegate? = nil, authorizations: AuthenticationHandler.AuthorizationsModel, authenticatedUser: AuthenticationHandler.AuthenticatedUser? = nil, delegator: AuthenticationHandler.Delegator? = nil) {
            self.apiKey = apiKey
            self.clientID = clientID
            self.azureOrDcs = azureOrDcs
            self.nonce = nonce
            self.azure = azure
            self.delegate = delegate
            self.authorizations = authorizations
            self.authenticatedUser = authenticatedUser
            self.delegator = delegator
        }
       
        enum CodingKeys: String, CodingKey {
            case apiKey = "api-key"
            case clientID = "client_id"
            case azureOrDcs
            case nonce
            case azure
            case delegate
            case authorizations
            case authenticatedUser
            case delegator
        }
    }
    
    public struct AuthorizationsModel: Codable {
        let roles: [String]
        
        public init(roles: [String]) {
            self.roles = roles
        }
    }
    
    public struct Azure: Codable {

        let name: String
        let email: String
        
        public init(name: String = "", email: String = "") {
            self.name = name
            self.email = email
        }
    }

    public struct AuthenticatedUser: Codable {
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
        
        public init(skatQAALevel: String = "", eIdentifier: String, typeOfIdentifier: String = "", alternateIdentifier: String = "", alternateIdentifierType: String = "", alternateName: String = "", legalname: String = "", typeOfActor: String = "", typeOfPerson: String = "", countryCode: String = "") {
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
    }
    public struct Delegator: Codable {
        
        let identifier: String
        let typeOfIdentifier: String
        let alternateIdentifier: String
        let alternateIdentifierType: String
        let alternateName: String
        let legalname: String
        let typeOfActor: String
        let typeOfPerson: String
        let countryCode: String
        
        public init(identifier: String = "", typeOfIdentifier: String = "", alternateIdentifier: String = "", alternateIdentifierType: String = "", alternateName: String = "", legalname: String = "", typeOfActor: String = "", typeOfPerson: String = "", countryCode: String = "") {
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
    }
}

public struct Delegate: Codable {
    
    let identifier: String
    let typeOfIdentifier: String
    let alternateIdentifier: String
    let alternateIdentifierType: String
    let alternateName: String
    let legalname: String
    let typeOfActor: String
    let typeOfPerson: String
    let countryCode: String
    
    public init(identifier: String = "", typeOfIdentifier: String = "", alternateIdentifier: String = "", alternateIdentifierType: String = "", alternateName: String = "", legalname: String = "", typeOfActor: String = "", typeOfPerson: String = "", countryCode: String = "") {
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
}
