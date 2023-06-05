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
