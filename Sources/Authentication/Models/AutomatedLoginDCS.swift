//
//  File.swift
//  
//
//  Created by Nicolai Dam on 19/05/2023.
//

import Foundation

extension AuthenticationHandler {
    public struct AutomatedLoginJSON: Codable, Equatable {
        public let url: String
        public let users: [UserItem]
    }
}

public enum UserItem: Equatable, Hashable, Codable {
    
    case dcs(AutomatedLoginDCSUser)
    case azure(AutomatedLoginAzureUser)
}

public extension UserItem {
    
    
    private enum CodingKeys: String, CodingKey {
        case azureOrDcs = "azureOrDcs"
    }
    
    init(from decoder: Decoder) throws {
        
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
                let singleContainer = try decoder.singleValueContainer()
                
        let type = try container.decode(String.self, forKey: .azureOrDcs)
                switch type {
                case "azure":
                    let azureUser = try singleContainer.decode(AutomatedLoginAzureUser.self)
                    self = .azure(azureUser)
                case "dcs":
                    let dcsUser = try singleContainer.decode(AutomatedLoginDCSUser.self)
                    self = .dcs(dcsUser)
                default:
                    fatalError("Unknown type of content.")
                }
    }
    
    enum Key: CodingKey {
        case rawValue
    }
    
    func encode(to encoder: Encoder) throws {
           var container = encoder.container(keyedBy: Key.self)
           switch self {
           case .dcs:
               try container.encode(0, forKey: .rawValue)
           case .azure:
               try container.encode(1, forKey: .rawValue)
           }
       }
}


public struct AutomatedLoginDCSUser: Codable, Equatable, Identifiable, Hashable {
    
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
            authorizations: AuthenticationHandler.AuthorizationsModel(roles: []),
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
        public let roles: [String]
    }
}


public struct AutomatedLoginAzureUser: Codable, Equatable, Identifiable, Hashable {
    
    public var id: String { title }

    let title: String
    let apiKey: String
    let clientID: String
    let azureOrDcs: String = "dcs"
    let nonce: String
    let azure: Azure
    let authorizations: Authorizations
    
    enum CodingKeys: String, CodingKey {
        case title
        case apiKey = "api-key"
        case clientID = "client_id"
        case azureOrDcs
        case nonce
        case azure
        case authorizations
    }
    
    var asJsonData: Data? {
        let encoder = JSONEncoder()
        let body = AuthenticationHandler.AutomatedLoginRequestBody(
            apiKey: self.apiKey,
            clientID: self.clientID,
            azureOrDcs: "azure",
            nonce: self.nonce,
            azure: AuthenticationHandler.Azure(name: self.azure.name, email: self.azure.email),
            authorizations: AuthenticationHandler.AuthorizationsModel(roles: self.authorizations.roles)
        )
        let jsonData = try? encoder.encode(body)
        return jsonData
    }
}


public extension AutomatedLoginAzureUser {
    struct Azure: Codable, Equatable, Hashable {
        public let name: String
        public let email: String
    }
    
    struct Authorizations: Codable, Equatable, Hashable {
        public let roles: [String]
    }
}
