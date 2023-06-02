//
//  File.swift
//  
//
//  Created by Nicolai Dam on 19/05/2023.
//

import Foundation

public struct AutomatedLoginDCSUser: Codable, Equatable, Identifiable, Hashable {
    
    public init(title: String, apiKey: String, clientID: String, nonce: String, dcs: AutomatedLoginDCSUser.Dcs, authorizations: AutomatedLoginDCSUser.Authorizations) {
        self.title = title
        self.apiKey = apiKey
        self.clientID = clientID
        self.nonce = nonce
        self.dcs = dcs
        self.authorizations = authorizations
    }
    
    
    public var id: String { title }
    
    let title: String
    let apiKey: String
    let clientID: String
    let azureOrDcs: String = "dcs"
    let nonce: String
    let dcs: Dcs
    let authorizations: Authorizations
    
    enum CodingKeys: String, CodingKey {
        case title
        case apiKey = "api-key"
        case clientID = "client_id"
        case azureOrDcs
        case nonce
        case dcs
        case authorizations
    }
    
    var asJsonData: Data? {
        let encoder = JSONEncoder()
        let body = AuthenticationHandler.AutomatedLoginRequestBody(
            apiKey: self.apiKey,
            clientID: self.clientID,
            azureOrDcs: "dcs",
            nonce: self.nonce,
            azure: AuthenticationHandler.Azure(),
            delegate: Delegate(),
            authorizations: AuthenticationHandler.AuthorizationsModel(roles: self.authorizations.roles),
            authenticatedUser: AuthenticationHandler.AuthenticatedUser(
                skatQAALevel: self.dcs.authenticatedUser.skatQAALevel,
                eIdentifier: self.dcs.authenticatedUser.eIdentifier,
                typeOfIdentifier: self.dcs.authenticatedUser.typeOfIdentifier,
                alternateIdentifier: self.dcs.authenticatedUser.alternateIdentifier,
                alternateIdentifierType: self.dcs.authenticatedUser.alternateIdentifierType,
                alternateName: self.dcs.authenticatedUser.alternateName,
                legalname: self.dcs.authenticatedUser.legalname,
                typeOfActor: self.dcs.authenticatedUser.typeOfActor,
                typeOfPerson: self.dcs.authenticatedUser.typeOfPerson,
                countryCode: self.dcs.authenticatedUser.countryCode
            ),
            delegator: AuthenticationHandler.Delegator(
                identifier: self.dcs.delegator.identifier,
                typeOfIdentifier: self.dcs.delegator.typeOfIdentifier,
                alternateIdentifier: self.dcs.delegator.alternateIdentifier,
                alternateIdentifierType: self.dcs.delegator.alternateIdentifierType,
                alternateName: self.dcs.delegator.alternateName,
                legalname: self.dcs.delegator.legalname,
                typeOfActor: self.dcs.delegator.typeOfActor,
                typeOfPerson: self.dcs.delegator.typeOfPerson,
                countryCode: self.dcs.delegator.countryCode
            )
        )
        let jsonData = try? encoder.encode(body)
        return jsonData
    }
}

public extension AutomatedLoginDCSUser {
    struct Dcs: Codable, Equatable, Hashable {
        public init(authenticatedUser: AutomatedLoginDCSUser.AuthenticatedUser, delegator: AutomatedLoginDCSUser.Delegator) {
            self.authenticatedUser = authenticatedUser
            self.delegator = delegator
        }
        
        public let authenticatedUser: AuthenticatedUser
        public let delegator: Delegator
    }
    
    struct AuthenticatedUser: Codable, Equatable, Hashable {
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
    
    struct Delegator: Codable, Equatable, Hashable {
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
    
    struct Authorizations: Codable, Equatable, Hashable {
        public init(roles: [String]) {
            self.roles = roles
        }
        
        public let roles: [String]
    }
}
