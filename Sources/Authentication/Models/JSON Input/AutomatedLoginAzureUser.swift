//
//  File.swift
//  
//
//  Created by Nicolai Dam on 25/05/2023.
//

import Foundation

public struct AutomatedLoginAzureUser: Codable, Equatable, Identifiable, Hashable {
    
    public var id: String { title }

    let title: String
    let apiKey: String
    let clientID: String
    let azureOrDcs: String = "dcs"
    let nonce: String
    let azure: Azure
    let authorizations: Authorizations
    
    var asRequestBody: AuthenticationHandler.AutomatedLoginRequestBody {
        let body = AuthenticationHandler.AutomatedLoginRequestBody(
            apiKey: self.apiKey,
            clientID: self.clientID,
            azureOrDcs: "azure",
            nonce: self.nonce,
            azure: AuthenticationHandler.Azure(name: self.azure.name, email: self.azure.email),
            authorizations: AuthenticationHandler.AuthorizationsModel(roles: self.authorizations.roles)
        )
        return body
    }
    
    public init(
        title: String,
        apiKey: String,
        clientID: String,
        nonce: String,
        azure: AutomatedLoginAzureUser.Azure,
        authorizations: AutomatedLoginAzureUser.Authorizations
    ) {
        self.title = title
        self.apiKey = apiKey
        self.clientID = clientID
        self.nonce = nonce
        self.azure = azure
        self.authorizations = authorizations
    }
    
    enum CodingKeys: String, CodingKey {
        case title
        case apiKey = "api-key"
        case clientID = "client_id"
        case azureOrDcs
        case nonce
        case azure
        case authorizations
    }
}


public extension AutomatedLoginAzureUser {
    struct Azure: Codable, Equatable, Hashable {
        
        public let name: String
        public let email: String
        
        public init(name: String, email: String) {
            self.name = name
            self.email = email
        }
    }
    
    struct Authorizations: Codable, Equatable, Hashable {
        
        public let roles: [String]
        
        public init(roles: [String]) {
            self.roles = roles
        }
    }
}
