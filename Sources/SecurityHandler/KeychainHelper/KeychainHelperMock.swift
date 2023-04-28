//
//  File.swift
//  
//
//  Created by Emad Ghorbaninia on 26/04/2023.
//

import Foundation
class MockKeychainHelper: KeychainHelperProtocol {
    private static var store: [String: CFTypeRef] = [:]

    static func search(matching cfDictionary: CFDictionary) -> Data? {
        guard let queryDictionary = cfDictionary as? [String: CFTypeRef],
              let keyIdentifier = queryDictionary[kSecAttrApplicationTag as String] as? String else {
            return nil
        }
        return  store[keyIdentifier] as? Data
    }
    

    static func remove(cfDictionary: CFDictionary) -> Bool {
        guard let queryDictionary = cfDictionary as? [String: CFTypeRef],
              let keyIdentifier = queryDictionary[kSecAttrApplicationTag as String] as? String else {
            return false
        }
        store.removeValue(forKey: keyIdentifier)
        return true
    }
    
    static func update(cfDictionary: CFDictionary) -> Bool {
        guard let queryDictionary = cfDictionary as? [String: CFTypeRef],
              let keyData = queryDictionary[kSecValueData as String],
              let keyIdentifier = queryDictionary[kSecAttrApplicationTag as String] as? String else {
            return false
        }
        store[keyIdentifier] = keyData
        return true
    }
    
    static func create(cfDictionary: CFDictionary) -> Bool {
        guard let queryDictionary = cfDictionary as? [String: CFTypeRef],
              let keyData = queryDictionary[kSecValueData as String],
              let keyIdentifier = queryDictionary[kSecAttrApplicationTag as String] as? String else {
            return false
        }
        store[keyIdentifier] = keyData
        return true
    }
    
}
