//
//  File.swift
//  
//
//  Created by Emad Ghorbaninia on 26/04/2023.
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

extension SecurityHandler {
    
    public class KeychainHelper: KeychainHelperProtocol {
        public static func search(matching cfDictionary: CFDictionary) -> Data? {
            var result: AnyObject?
            let status = SecItemCopyMatching(cfDictionary, &result)
            
            return status == noErr ? result as? Data : nil
            
        }
        public static func create(cfDictionary: CFDictionary) -> Bool {
            let status = SecItemAdd(cfDictionary as CFDictionary, nil)
            
            switch status {
            case errSecSuccess:
                return true
            case errSecDuplicateItem:
                return update(cfDictionary: cfDictionary)
            default:
                return false
            }
        }
        public static func update(cfDictionary: CFDictionary) -> Bool {
            var dictionary: CFDictionary
            var update: CFDictionary
            if let queryDictionary = cfDictionary as? [String: CFTypeRef],
               let keyData = queryDictionary[kSecValueData as String]{
                dictionary = cfDictionary
                update = [secValueData: keyData] as CFDictionary
                let status = SecItemUpdate(dictionary as CFDictionary, update as CFDictionary)
                
                return status == errSecSuccess
            } else {
                return false
            }
        }
        public static func remove(cfDictionary: CFDictionary) -> Bool {
            var dictionary: CFDictionary
            dictionary = cfDictionary
            let status = SecItemDelete(dictionary as CFDictionary)
            return status == errSecSuccess
        }
    }
}

extension SecurityHandler.KeychainHelper {
    @discardableResult
    public static func remove(identifier: String) -> Bool {
        var dictionary: CFDictionary
        
        dictionary = setupSearchDirectory(for: identifier) as CFDictionary
        let status = SecItemDelete(dictionary as CFDictionary)
        return status == errSecSuccess
        
    }

    
    @discardableResult
    public static func create(value: String, forIdentifier identifier: String) -> Bool {
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
    }

    public static func string(matching identifier: String) -> String? {
        guard let data = search(matching: identifier) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }

    private static func search(matching identifier: String) -> Data? {
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
    private static func update(value: String, forIdentifier identifier: String) -> Bool {
        var dictionary: CFDictionary
        var update: CFDictionary
        
        dictionary = setupSearchDirectory(for: identifier) as CFDictionary
        let encodedValue = value.data(using: .utf8)
        update = [secValueData: encodedValue] as CFDictionary
        let status = SecItemUpdate(dictionary as CFDictionary, update as CFDictionary)
        
        return status == errSecSuccess
    }
    private static func setupSearchDirectory(for identifier: String) -> [String: Any] {
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

}
