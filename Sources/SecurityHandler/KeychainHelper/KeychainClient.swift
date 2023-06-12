//
//  File.swift
//  
//
//  Created by Nicolai Dam on 31/05/2023.
//

import Foundation

private let secClass = kSecClass as String
private let secAttrService = kSecAttrService as String
private let secAttrGeneric = kSecAttrGeneric as String
private let secAttrAccount = kSecAttrAccount as String
private let secMatchLimit = kSecMatchLimit as String
private let secReturnData = kSecReturnData as String
private let secValueData = kSecValueData as String
private let secAttrAccessible = kSecAttrAccessible as String

public struct KeychainClient {
     public var getString: (_ identifier: String) -> String?
     public var save: (_ value: String, _ forIdentifier: String) -> Bool
     public var remove: (_ identifier: String) -> Bool
}

public extension KeychainClient {
    
    static let live = Self.init(
        getString: { identifier in
            guard let data = search(matching: identifier) else {
                return nil
            }
            
            return String(data: data, encoding: .utf8)
        },
        save: { value, identifier in
            var dictionary: CFDictionary
            
            var localDictionary = setupSearchDirectory(for: identifier)
            
            let encodedValue = value.data(using: .utf8)
            localDictionary[secValueData] = encodedValue
            
            // Protect the keychain entry so its only valid when the device is unlocked
            localDictionary[secAttrAccessible] = kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
            dictionary = localDictionary as CFDictionary
            let status = SecItemAdd(dictionary as CFDictionary, nil)
            
            switch status {
            case errSecSuccess:
                return true
            case errSecDuplicateItem:
                return update(value: value, forIdentifier: identifier)
            default:
                return false
            }
            
        },
        remove: { identifier in
            var dictionary: CFDictionary
            
            dictionary = setupSearchDirectory(for: identifier) as CFDictionary
            let status = SecItemDelete(dictionary as CFDictionary)
            return status == errSecSuccess
        }
    )
}

func search(matching identifier: String) -> Data? {
    var dictionary: CFDictionary
    
    var localDictionary = setupSearchDirectory(for: identifier)
    
    // Limit search results to one
    localDictionary[secMatchLimit] = kSecMatchLimitOne
    
    // Specify we want NSData/CFData returned
    localDictionary[secReturnData] = kCFBooleanTrue
    
    dictionary = localDictionary as CFDictionary
    var result: AnyObject?
    let status = SecItemCopyMatching(dictionary as CFDictionary, &result)
    
    return status == noErr ? result as? Data : nil
}

func update(value: String, forIdentifier identifier: String) -> Bool {
    var dictionary: CFDictionary
    var update: CFDictionary
    
    dictionary = setupSearchDirectory(for: identifier) as CFDictionary
    let encodedValue = value.data(using: .utf8)
    update = [secValueData: encodedValue] as CFDictionary
    let status = SecItemUpdate(dictionary as CFDictionary, update as CFDictionary)
    
    return status == errSecSuccess
}

func setupSearchDirectory(for identifier: String) -> [String: Any] {
    // We are looking for passwords
    var searchDictionary: [String: Any] = [secClass: kSecClassGenericPassword]
    
    // Identify our access
    searchDictionary[secAttrService] = Bundle.main.bundleIdentifier
    
    // Uniquely identify the account who will be accessing the keychain
    let encodedIdentifier = identifier.data(using: .utf8)
    searchDictionary[secAttrGeneric] = encodedIdentifier
    searchDictionary[secAttrAccount] = encodedIdentifier
    
    return searchDictionary
}

