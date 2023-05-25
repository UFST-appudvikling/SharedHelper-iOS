//
//  File.swift
//  
//
//  Created by Nicolai Dam on 25/05/2023.
//

import Foundation

/// JSON model for automated test users that is stored in the individual app project
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

